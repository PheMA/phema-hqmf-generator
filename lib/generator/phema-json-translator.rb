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

        # Need to build into authoring tool, including title & other metadata in the JSON that we
        # get sent.
        measure = HQMF::Document.from_json({
          "title" => "Test Measure",
          "description" => "This is a test measure",
          "hqmf_version_number" => "v1",  # This is the internal measure version, not a formal CMS version
          "population_criteria" => [],
          "source_data_criteria" => {
          },
          "data_criteria" => build_data_criteria,
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
        })
        measure.to_json
        #HQMF2::Generator::ModelProcessor.to_hqmf(measure);
      end

      def build_data_criteria
        return {} if @id_element_map.empty?

        formatted_items = @id_element_map.map do |key, val|
          [ val["hds_name"], phema_data_type_to_hds_json(val) ] unless val["hds_name"].nil?
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
      def phema_data_type_to_hds_json element
        value_set = get_value_set_for_element element

        @hds_translator.data_criteria(
          element["attrs"]["element"]["uri"],
          {
            :code => value_set["id"],
            :title => value_set["name"]
          }, nil, nil, false, false, ''
        )
      end

      # TODO: recursively build nested operators
      def build_logical_operators element
        operators = find_logical_operators(element)

        # Get the identifiers of elements that are in this logical operator
        hqmf_operators = []
        operators.each do |operator|
          element_ids = operator["attrs"]["phemaObject"]["containedElements"].map{ |el| el["id"] }

          # Search the overall elements by these IDs
          elements = []
          element_ids.each { |id| elements << @id_element_map[id] }
          elements.compact!

          # Build the HDS structures for this operator
          hqmf_type = PhEMA::HealthDataStandards::QDM_HQMF_LOGICAL_CONJUNCTION_MAPPING[operator["attrs"]["element"]["uri"]]
          operator_definition = {
            "conjunction_code" => hqmf_type,
            "preconditions" => elements.map do |el|
              item = { "id" => el["id"] }
              if el["hds_name"]
                item["reference"] = el["hds_name"]
              else
                item["preconditions"] = build_logical_operators(operator)
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
          if child["className"] == "PhemaGroup"
            @id_element_map[child["id"]] = child
            # Add in the generated name so it's saved and can be reused, but only for datatypes or categories
            if child["attrs"]["element"]["type"] == "DataElement" or child["attrs"]["element"]["type"] == "Category"
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