module PhEMA
  module HealthDataStandards
    class JsonTranslator
      def self.measure_score(measure_score)
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

      def self.measure_type(measure_type)
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

      def self.measure_period(start_date, end_date)
        {
          "low" => {
            "value" => start_date.nil? ? "19000101" : start_date
          },
          "high" => {
            "value" => end_date.nil? ? Time.now.strftime("%Y%m%d") : end_date
          }
        }
      end

      def self.reference(text)
        text_attribute("REF", "Reference", text)
      end

      def self.definition(text)
        text_attribute("DEF", "Definition", text)
      end

      def self.initial_population(text)
        text_attribute("IPOP", "Initial Population", text)
      end

      def self.text_attribute(code, name, value)
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

      def self.severity(valueSetId, title)
        if (valueSetId.nil?)
          return nil
        end

        {
          "type" => "CD",
          "code_list_id" => valueSetId,
          "title" => title
        }
      end

      def self.data_criteria(qdmType, valueSet, attributes, isNegated, isVariable, sourceId)
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
          "definition" => hqmf[:definition],
          "description" => hqmf[:description],
          "hard_status" => false,
          "negation" => isNegated,
          "source_data_criteria" => sourceId,
          "status" => hqmf[:status],
          #"title" => hqmf[:description],
          "type" => hqmf[:type],
          "variable" => isVariable,
          "field_values" => {}
        }

        unless(attributes.nil?)
          unless (attributes[:severity].nil?)
            result["field_values"]["SEVERITY"] = severity(attributes[:severity][:code], attributes[:severity][:title])
          end

          unless (attributes[:ordinal].nil?)
            result["field_values"]["ORDINAL"] = {"code_list_id" => attributes[:ordinal][:code]}
          end
        end

        result
      end

      private

      def self.get_measure_score_title(measure_score)
        case
          when measure_score == "COHORT" then "Cohort"
          when measure_score == "CONTVAR" then "Continuous variable"
          when measure_score == "PROPOR" then "Proportion"
          when measure_score == "RATIO" then "Ratio"
          else measure_score
        end
      end

      def self.get_measure_type_title(measure_type)
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