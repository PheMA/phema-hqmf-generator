module PhEMA
  module HealthDataStandards
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
            "value" => start_date.nil? ? "19000101" : start_date
          },
          "high" => {
            "value" => end_date.nil? ? Time.now.strftime("%Y%m%d") : end_date
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

      def data_criteria(qdmType, valueSet, attributes, effectiveTime, isNegated, isVariable, sourceId)
        hqmf = QDM_HQMF_MAPPING.detect { |x| x[:id] == qdmType }
        unless (hqmf)
          return nil
        end

        result = {
          "value" => {
            "type" => "CD",
            "code_list_id" => valueSet[:code],
            "title" => valueSet[:title],
          },
          "inline_code_list" => hqmf[:code],
          "code_list_id" => valueSet[:code],
          "definition" => hqmf[:definition],
          "description" => hqmf[:description],
          "hard_status" => false,
          "negation" => isNegated,
          "source_data_criteria" => sourceId,
          "status" => hqmf[:status],
          "type" => hqmf[:type],
          "variable" => isVariable,
          "field_values" => {},
          "effective_time" => effectiveTime
        }

        unless(attributes.nil?)
          attributes.each_pair do |key, value|
            result["field_values"][key.to_s.upcase] = { "type" => "CD", "code_list_id" => value[:code], "title" => value[:title]}
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
          return nil
        end

        id ||= @data_element_counter

        name = (hqmf[:description] + '_' + valueSet).gsub(/[\s,]{2,}/, ' ').gsub(/[\s]/, '_') + '_' + id.to_s
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