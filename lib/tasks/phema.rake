require 'pathname'
require 'fileutils'
require 'json'
require 'health-data-standards'
require 'hqmf-parser'
require_relative "../phema-hqmf-generator"

namespace :phema do

  desc 'Parse all xml files to JSON and save them to ./tmp'
  task :generate, [:path] do |t, args|

    #raise "You must specify the JSON file path to convert" unless args.path
    measure = HQMF::Document.from_json({
      "title" => "Test Measure",
      "description" => "This is a test measure",
      "hqmf_version_number" => "v1",  # This is the internal measure version, not a formal CMS version
      "population_criteria" => [],
      "data_criteria" => [],
      "source_data_criteria" => {
        "SomeTestActiveDiagnosis" => PhEMA::HealthDataStandards::JsonTranslator.data_criteria(
          "http://rdf.healthit.gov/qdm/element#DiagnosisActive",
          { :code => "2.16.840.1.113883.3.666.5.225", :title => "Any diagnosis of this type" },
          {
            :severity => {:code => "2.16.840.1.113883.3.666.5.226", :title => "List of severity codes" },
            :ordinal => {:code => "2.16.840.1.113883.3.666.5.227" }
          },
          false, false, '')
      },
      "attributes" => [
        PhEMA::HealthDataStandards::JsonTranslator.measure_score("COHORT"),
        PhEMA::HealthDataStandards::JsonTranslator.measure_type("OUTCOME"),
        PhEMA::HealthDataStandards::JsonTranslator.text_attribute("REF", "Reference", "Sample document")
      ],
      "measure_period" => PhEMA::HealthDataStandards::JsonTranslator.measure_period(nil, nil),
      "data_criteria" => {
        "SomeTestActiveDiagnosis" => PhEMA::HealthDataStandards::JsonTranslator.data_criteria(
          "http://rdf.healthit.gov/qdm/element#DiagnosisActive",
          { :code => "2.16.840.1.113883.3.666.5.225", :title => "Any diagnosis of this type" },
          {
            :severity => {:code => "2.16.840.1.113883.3.666.5.226", :title => "List of severity codes" },
            :ordinal => {:code => "2.16.840.1.113883.3.666.5.227" }
          },
          false, false, "SomeTestActiveDiagnosis")
      }
    })
    puts HQMF2::Generator::ModelProcessor.to_hqmf(measure);
  end
end