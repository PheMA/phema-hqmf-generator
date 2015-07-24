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
        {
          "name" => "Reference",
          "code" => "REF",
          "code_obj" => {
            "code" => "REF",
            "system" => "2.16.840.1.113883.5.4",
            "title" => "Reference",
            "type" => "ED"
          },
          "value_obj" => {
            "value" => text.nil? ? '' : text.encode(:xml => :text)
          }
        }
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
    end
  end
end