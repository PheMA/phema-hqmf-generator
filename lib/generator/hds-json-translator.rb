module PhEMA
  module HDS
    class JsonTranslator
      def initialize
        @data_element_counter = 1
      end

      def measure_score(measure_score)
        {
          "name" => "Measure scoring",
          "code" => "MSRSCORE",
          "code_obj" => {
            "code" => "MSRSCORE",
            "system" => "2.16.840.1.113883.5.4",
            "title" => "Measure Scoring",
            "type" => "CD"
          },
          "value_obj" => {
            "code" => measure_score,
            "system" => "2.16.840.1.113883.1.11.20367",
            "title" => get_measure_score_title(measure_score),
            "type" => "CD"
          }
        }
      end

      def measure_type(measure_type)
        {
          "name" => "Measure Type",
          "code" => "MSRTYPE",
          "code_obj" => {
            "code" => "MSRTYPE",
            "system" => "2.16.840.1.113883.5.4",
            "title" => "Measure Type",
            "type" => "CD"
          },
          "value_obj" => {
            "code" => measure_type,
            "system" => "2.16.840.1.113883.1.11.20368",
            "title" => get_measure_type_title(measure_type),
            "type" => "CD"
          }
        }
      end

      def measure_period(start_date, end_date)
        {
          "low" => {
            "value" => start_date.nil? ? "190001010000" : start_date
          },
          "high" => {
            "value" => end_date.nil? ? Time.now.strftime("%Y%m%d%H%M") : end_date
          }
        }
      end

      def reference(text)
        text_attribute("REF", "Reference", text)
      end

      def definition(text)
        text_attribute("DEF", "Definition", text)
      end

      def initial_population(text)
        text_attribute("IPOP", "Initial Population", text)
      end

      def text_attribute(code, name, value)
        {
          "name" => name,
          "code" => code,
          "code_obj" => {
            "code" => code,
            "system" => "2.16.840.1.113883.5.4",
            "title" => name,
            "type" => "ED"
          },
          "value_obj" => {
            "value" => value.nil? ? '' : value.encode(:xml => :text)
          }
        }
      end

      def severity(valueSetId, title)
        if (valueSetId.nil?)
          return nil
        end

        {
          "type" => "CD",
          "code_list_id" => valueSetId,
          "title" => title
        }
      end

      # Determine if the element is a function or operator that is used as a subset attribugte for a
      # data element.
      def is_subset_function qdmType
        QDM_HQMF_SUBSET_FUNCTIONS.any?{ |x| x[:id] == qdmType }
      end

      # Some of the functions need special handling.  They are represented as a simple function (e.g. Age At)
      # but in the HQMF need to be translated to a birthdate element with a temporal reference.
      def is_age_function_reference qdmType
        QDM_HQMF_AGE_FUNCTIONS.any? { |x| x[:id] == qdmType }
      end

      def get_value_set_oid(qdmType, valueSet)
        if is_age_function_reference(qdmType)
          "2.16.840.1.113883.3.560.100.4"  # Birthdate
        else
          valueSet["id"]
        end
      end

      # qdmType - URI (from Data Element Repository) to represent the type
      def data_criteria(qdmType, valueSet, value, attributes, effectiveTime, isNegated, isVariable, sourceId, temporalReferences, subsets)
        hqmf = QDM_HQMF_MAPPING.detect { |x| x[:id] == qdmType }
        unless (hqmf)
          return nil
        end

        result = {
          "value" => value,
          "title" => valueSet["name"],
          "display_name" => valueSet["name"],
          "code_list_id" => get_value_set_oid(qdmType, valueSet),
          "definition" => hqmf[:definition],
          "description" => hqmf[:description] + ": " + valueSet["name"],
          "hard_status" => false,
          "negation" => isNegated,
          "source_data_criteria" => sourceId,
          "status" => hqmf[:status],
          "type" => hqmf[:type],
          "variable" => isVariable,
          "field_values" => {},
          "effective_time" => effectiveTime
        }

        is_age_function = is_age_function_reference(qdmType)

        # If the value is a value set that matches the code_list_id, it's duplicative and we
        # can just remove it.
        if !result["code_list_id"].nil? && !result["value"].nil? && !result["value"]["code_list_id"].nil? && result["code_list_id"] == result["value"]["code_list_id"]
          result.delete("value")
        end

        # If this is an age function, we have some special manipulation to do
        if is_age_function
          result["title"] = hqmf[:description]
          result["display_name"] = hqmf[:description]
          result.delete("value")
          result.delete("status")
          result["inline_code_list"] = { "LOINC" => [ "21112-8" ] }  # Birth date
        end

        unless temporalReferences.nil?
          result["temporal_references"] = temporalReferences
        end

        unless subsets.nil?
          result["subset_operators"] = subsets
        end

        unless(attributes.nil?)
          attributes.each_pair do |key, value|
            value_hash = { "type" => value["type"] }
            if value["type"] == "IVL_PQ" or value["type"] == "PQ"
              value_hash["low"] = value["low"] if value["low"]
              value_hash["high"] = value["high"] if value["high"]
            elsif value["type"] != HQMF::AnyValue
              value_hash["code_list_id"] = value["code"]
              value_hash["title"] = value["title"]
            end
            result["field_values"][key.to_s.upcase] = value_hash
          end
        end

        result
      end

      # Generates a unique name for an entity
      # @param qdmType [String] The URI for the QDM element type
      # @param valueSet [String] A name/descriptor for the value set associated with the element
      # @param id [String] An optional unique identifier from the source system.  If no identifier is available, and internal ID will be assigned.
      # @return [String] The generated name for the entity, ready for use in the HDS structure.
      def generate_entity_name(qdmType, valueSet, id = nil)
        hqmf = QDM_HQMF_MAPPING.detect { |x| x[:id] == qdmType }
        unless (hqmf)
          hqmf = QDM_HQMF_SUBSET_FUNCTIONS.detect { |x| x[:id] == qdmType }
          return nil unless hqmf
        end

        id ||= @data_element_counter
        valueSet ||= ''

        #name = (hqmf[:description] + '_' + valueSet).gsub(/[\s,]{2,}/, ' ').gsub(/[\s]/, '_') + '_' + id.to_s
        name = (hqmf[:description] + '_' + valueSet).gsub(/[^0-9a-zA-Z]/, '_')
        name = name + '_' + id.to_s unless id.nil?
        @data_element_counter = @data_element_counter + 1  # Increment, even if it's never used
        name
      end

      private

      def get_measure_score_title(measure_score)
        case
          when measure_score == "COHORT" then "Cohort"
          when measure_score == "CONTVAR" then "Continuous variable"
          when measure_score == "PROPOR" then "Proportion"
          when measure_score == "RATIO" then "Ratio"
          else measure_score
        end
      end

      def get_measure_type_title(measure_type)
        case
          when measure_type == "OUTCOME" then "Outcome"
          when measure_type == "PROCESS" then "Process"
          when measure_type == "COMPOSITE" then "Composite"
          when measure_type == "RESOURCE" then "Resource"
          when measure_type == "EFFICIENCY" then "Efficiency"
          when measure_type == "EXPERIENCE" then "Experience"
          when measure_type == "STRUCTURE" then "Structure"
          else measure_type
        end
      end
    end
  end
end