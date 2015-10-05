require 'json'
require 'hqmf-parser'

module PhEMA
  module Phenotype
    # Takes the output of the PhEMA authoring tool (a JSON-based phenotype definition), and converts it
    # into the Health Data Standards (HDS) JSON format.
    class JsonTranslator
      def initialize
        @hds_translator = PhEMA::HealthDataStandards::JsonTranslator.new
        @id_element_map = Hash.new
      end

      def to_hds json_string
        phenotype = JSON.parse(json_string)
        return if phenotype.nil?
        build_id_element_map(phenotype)
        hds_logical_operators = build_logical_operators(phenotype)
        data_criteria = build_data_criteria(false)
        source_data_criteria = build_data_criteria(true)

        # Need to build into authoring tool, including title & other metadata in the JSON that we
        # get sent.
        measure_definition = {
          #"title" => "Test Measure",
          #"description" => "This is a test measure",
          "hqmf_version_number" => "v1",  # This is the internal measure version, not a formal CMS version
          "source_data_criteria" => source_data_criteria,
          "data_criteria" => data_criteria,
          "attributes" => [
            @hds_translator.measure_score("COHORT"),
            @hds_translator.measure_type("OUTCOME"),
            @hds_translator.text_attribute("REF", "Reference", "Sample document")
          ],
          "measure_period" => @hds_translator.measure_period(nil, nil),
          "population_criteria" => {
            "IPP" => { "type" => "IPP", "title" => "Initial Patient Population",
              "conjunction_code" => "allTrue",
              "preconditions" => hds_logical_operators
            }
          }
        }
        measure_definition = set_phenotype_metadata(phenotype, measure_definition)

        measure = HQMF::Document.from_json(measure_definition)
        measure
      end

      def set_phenotype_metadata phenotype, measure
        if phenotype["attrs"] and phenotype["attrs"]["phenotypeData"]
          measure["title"] = phenotype["attrs"]["phenotypeData"]["name"]
          measure["description"] = phenotype["attrs"]["phenotypeData"]["description"]
        end
        measure
      end

      def to_hqmf json_string
        HQMF2::Generator::ModelProcessor.to_hqmf(to_hds(json_string));
      end

      def to_hds_json json_string
        to_hds(json_string).to_json.to_json
      end

      def build_data_criteria isSource
        return {} if @id_element_map.empty?

        formatted_items = @id_element_map.map do |key, val|
          [ val["hds_name"], phema_data_type_to_hds_json(val, isSource) ] unless val["hds_name"].nil?
        end

        Hash[formatted_items.compact]
      end

      # Locate a value set definition for a PhEMA element.  Return a stub definition if one doesn't exist.
      # @param element [Hash] The PhEMA element that contains a value set
      # @return [Hash] An ID and Name to define the value set.
      def get_value_set_for_element element
        value_set = element["children"].find{ |ch| ch["attrs"]["phemaObject"] and ch["attrs"]["phemaObject"]["className"] == "ValueSet" }
        return {"id" => "", "name" => "(Not specified)"} if value_set.nil?
        {"id" => value_set["attrs"]["element"]["id"], "name" => value_set["attrs"]["element"]["name"] }
      end

      # Builds up the HDS definition of a data element, given a PhEMA definition
      # @param element [Hash] The PhEMA element that will be converted
      # @return [Hash] The HDS JSON that defines a data element
      def phema_data_type_to_hds_json element, isSource
        value_set = get_value_set_for_element element
        result_range = get_result_attribute_for_element element

        @hds_translator.data_criteria(
          element["attrs"]["element"]["uri"],
          value_set,
          build_value_for_element(value_set, (result_range.nil? ? nil : result_range[1])),
          build_attributes_for_element(element),
          nil,  # Date range
          false, # Negated?
          false, # Is a variable?
          (isSource ? '' : element["hds_name"]),
          build_temporal_references_for_element(element),
          build_subsets_for_element(element)
        )
      end

      def build_subsets_for_element element
        [
          #{"type" => "THIRD"}
        ]
      end

      # Construct the appropriate value structure for an element
      # @param valueSet [Hash] The value set assigned to the element
      # @param range [Hash] The range value (if defined) for the element
      # @return [Hash] The HDS JSON for the element's value
      def build_value_for_element valueSet, value
        if value.nil?
          return {
            "type" => "CD",
            "code_list_id" => valueSet["id"],
            "title" => valueSet["name"],
          }
        else
          if value and value["type"]
            if value["type"] == "present"
              return {"type" => "ANYNonNull" }
            elsif value["type"] == "value"
              return build_range_hash(false, value["operator"], value["units"]["id"], value["valueLow"], value["valueHigh"])
            end
          end
        end
        nil
      end

      # Given an element, pull out the result range attribute and format it as HDS JSON
      # @param element [Hash] The PhEMA element we are interested in
      # @return [Array] The result attribute, or nil of none exists
      def get_result_attribute_for_element element
        return nil unless element["attrs"] and element["attrs"]["phemaObject"] and element["attrs"]["phemaObject"]["attributes"]
        attr_hash = Hash.new
        attribute = element["attrs"]["phemaObject"]["attributes"].find { |key, value| key == "Result" }
        attribute
      end

      # Build the array of temporal references that exist (if any) for an element.  Although temporal relationships
      # are bi-directional, the HQMF specification only wants to see the source -> target pair.
      # @param element [Hash] The PhEMA element we are interested in
      # @return [Array] The list of temporal relationships (Hash objects) where this element is the source.
      def build_temporal_references_for_element element
        # Get all of the connector items associated with this element.
        connectors = element["children"].find_all { |ch| ch["className"] == "PhemaConnector" }
        return nil unless connectors and connectors.length > 0
        # For each connector, look up the actual connection relationship that is associated with it.  There may be
        # multiple for a connector.
        connections = connectors.map { |connector| connector["attrs"]["connections"].map { |con| @id_element_map[con["id"]] } }.flatten!
        return nil unless connections and connections.length > 0

        temporal_references = []
        connections.each do |connection|
          start_id = connection["attrs"]["connectors"]["start"]["id"]
          # Am I the start or the end?  If I'm the end, skip because whoever the start element is will define the relationship
          matching_connector = element["children"].find { |ch| ch["id"] == start_id}
          if matching_connector
            end_element = @id_element_map.find { |key, val| val["children"].any?{ |ch| ch["id"] == connection["attrs"]["connectors"]["end"]["id"] } if val["children"] }
            unless end_element.nil?
              reference = { "reference" => end_element[1]["hds_name"], "type" => PhEMA::HealthDataStandards::QDM_HQMF_TEMPORAL_TYPE_MAPPING[connection["attrs"]["element"]["uri"]] }
              if connection["attrs"]["element"]["timeRange"] and connection["attrs"]["element"]["timeRange"]["comparison"]
                time_range = connection["attrs"]["element"]["timeRange"]
                reference["range"] = build_range_hash(true, time_range["comparison"], time_range["start"]["units"], time_range["start"]["value"], time_range["end"]["value"])
              end
              temporal_references << reference
            end
          end
        end

        temporal_references
      end

      # Build the attributes that have been defined for a specific QDM element
      # @param element [Hash] The PhEMA element we are interested in
      # @return [Hash] The HDS JSON that defines the attributes for the element
      def build_attributes_for_element element
        return nil unless element["attrs"] and element["attrs"]["phemaObject"] and element["attrs"]["phemaObject"]["attributes"]
        attr_hash = Hash.new
        attributes = element["attrs"]["phemaObject"]["attributes"]
        attributes.each do |key, value|
          # We need to handle result as a special entry, and so it's excluded from general attribute processing.
          # Result will be used when we define the value of the data element.
          if value and key != 'Result'
            attribute_symbol = key.underscore.to_sym
            if value.is_a?(Array)
              if value.length > 0
                attr_hash[attribute_symbol] = {:type => "CD", :code => value[0]["id"], :title => value[0]["name"]} if value[0]["type"] == "ValueSet"
              end
            elsif value["type"]
              if value["type"] == "present"
                attr_hash[attribute_symbol] = {:type => "ANYNonNull" }
              elsif value["type"] == "value"
                attr_hash[attribute_symbol] = build_range_hash(false, value["operator"], value["units"]["id"], value["valueLow"], value["valueHigh"])
              end
            end
          end
        end
        attr_hash
      end

      def build_range_hash is_temporal, operator, units, valueLow = nil, valueHigh = nil
        range = { "type" => "IVL_PQ" }
        if operator == "BW" or operator == "between"
          range["low"] = { "value" => valueLow, "unit" => units }
          range["high"] = { "value" => valueHigh, "unit" => units }
        elsif operator == "EQ" or operator == "exactly"
          range["low"] = { "type" => "PQ", "value" => valueLow, "unit" => units }
          range["high"] = { "type" => "PQ", "value" => valueLow, "unit" => units }
        else
          if operator[0] == 'L' or operator[0] == '<'
            range["high"] = { "type" => "PQ", "value" => valueLow, "unit" => units }
            range["high"]["inclusive?"] = true if operator == 'LE' or operator == '<='
            range["low"] = { "null_flavor" => "NINF", "inclusive?" => false } unless is_temporal
          elsif  operator[0] == 'G' or operator[0] == '>'
            range["low"] = { "type" => "PQ", "value" => valueLow, "unit" => units }
            range["low"]["inclusive?"] = true if operator == 'GE' or operator == '>='
            range["high"] = { "null_flavor" => "PINF", "inclusive?" => false } unless is_temporal
          else
            range = {}
          end
        end

        range
      end

      def build_logical_operators element
        operators = find_logical_operators(element)

        hqmf_operators = []

        if operators.empty?
          items = element["children"].find_all { |ch| ch["className"] == "PhemaGroup" }

          contained_elements = []
          items.each { |item| contained_elements << @id_element_map[item["id"]] }
          contained_elements.compact!
          hqmf_operators = items.map {|item| { "id" => item["id"], "reference" => item["hds_name"] }}
          puts hqmf_operators
          return hqmf_operators
        end

        operators.each do |operator|
          # Get the identifiers of elements that are in this logical operator
          element_ids = operator["attrs"]["phemaObject"]["containedElements"].map{ |el| el["id"] }

          # Search the overall elements by these IDs
          contained_elements = []
          element_ids.each { |id| contained_elements << @id_element_map[id] }
          contained_elements.compact!

          # Build the HDS structures for this operator
          hqmf_type = PhEMA::HealthDataStandards::QDM_HQMF_LOGICAL_CONJUNCTION_MAPPING[operator["attrs"]["element"]["uri"]]
          operator_definition = {
            "id" => operator["id"],
            "conjunction_code" => hqmf_type,
            "preconditions" => contained_elements.map do |el|
              item = { "id" => el["id"] }
              if el["hds_name"]
                item["reference"] = el["hds_name"]
              else
                item = build_logical_operators(operator).first
              end
              item
            end
          }
          hqmf_operators << operator_definition
        end

        hqmf_operators
      end

      def find_logical_operators phenotype
        return [] unless phenotype["children"]
        phenotype["children"].select { |item| item["attrs"] && item["attrs"]["phemaObject"] && item["attrs"]["phemaObject"]["className"] == 'LogicalOperator' }
      end

      # Recursively looks at all PhEMA objects (data elements, logical operators, etc.) within the phenotype
      # definition, and creates a flat mapping of IDs to the element. This will help speed future lookups.
      def build_id_element_map phenotype
        return unless phenotype["children"]

        # Loop through all immediate children
        phenotype["children"].each do |child|
          # Only select PhEMA objects - don't pull out KineticJS elements
          if child["className"] == "PhemaGroup" or child["className"] == "PhemaConnection"
            @id_element_map[child["id"]] = child
            # Add in the generated name so it's saved and can be reused, but only for datatypes or categories
            if child["attrs"]["element"]["type"] == "DataElement" or child["attrs"]["element"]["type"] == "Category" or child["attrs"]["element"]["type"] == "SubsetOperator"
              value_set = get_value_set_for_element child
              @id_element_map[child["id"]]["hds_name"] = @hds_translator.generate_entity_name(child["attrs"]["element"]["uri"], value_set["name"], child["id"])
            end
          end

          # Recursively process children
          if child["children"]
            build_id_element_map child
          end
        end

        @id_element_map
      end
    end
  end
end