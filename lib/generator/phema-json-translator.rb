require 'json'

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
        logical_operators = find_logical_operators(phenotype)
        build_logical_operators(logical_operators)

        # Need to build into authoring tool, including title & other metadata in the JSON that we
        # get sent.

        measure = HQMF::Document.from_json({
          "title" => "Test Measure",
          "description" => "This is a test measure",
          "hqmf_version_number" => "v1",  # This is the internal measure version, not a formal CMS version
          "population_criteria" => [],
          "source_data_criteria" => {
          },
          "data_criteria" => {
          },
          "attributes" => [
            @hds_translator.measure_score("COHORT"),
            @hds_translator.measure_type("OUTCOME"),
            @hds_translator.text_attribute("REF", "Reference", "Sample document")
          ],
          "measure_period" => @hds_translator.measure_period(nil, nil),
          "population_criteria" => {
            "IPP" => { "type" => "IPP", "title" => "Initial Patient Population",
              "conjunction_code" => "allFalse",
              "preconditions" => [
                { "id" => 10, "reference" => "test_dx_name" },
                { "id" => 11, "reference" => "test_med_name" }
              ]
            }
          }
        })
        measure.to_json
        #HQMF2::Generator::ModelProcessor.to_hqmf(measure);
      end

      # TODO: recursively build nested operators
      def build_logical_operators operators
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
          hqmf_operators << { "conjunction_code" => hqmf_type, "preconditions" => elements.map {|el| { "id" => el["id"], "reference" => "name" } } }
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
          @id_element_map[child["id"]] = child if child["className"] == "PhemaGroup"

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