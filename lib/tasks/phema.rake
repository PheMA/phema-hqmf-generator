require 'pathname'
require 'fileutils'
require 'json'
require 'health-data-standards'
require 'hqmf-parser'
require_relative "../phema-hqmf-generator"

namespace :phema do

  desc 'Parse all xml files to JSON and save them to ./tmp'
  task :generate, [:path] do |t, args|

        translater = PhEMA::HealthDataStandards::JsonTranslator.new

        # "SomeTestActiveDiagnosis" => PhEMA::HealthDataStandards::JsonTranslator.data_criteria(
          # "http://rdf.healthit.gov/qdm/element#DiagnosisActive",
          # { :code => "2.16.840.1.113883.3.666.5.225", :title => "Any diagnosis of this type" },
          # {
          #   :severity => {:code => "2.16.840.1.113883.3.666.5.226", :title => "List of severity codes" },
          #   :ordinal => {:code => "2.16.840.1.113883.3.666.5.227" },
          #   :anatomical_location => {:code => "1.2.3"},
          #   :method => {:code => "2.3.4" },
          #   :facility_location => {:code => "3.4.5" }
          # },
          # { "low" => { "value" => "20150101" }, "high" => { "value" => "20151231" } },
          # false, false, ''
        #)

        test_dx = translator.data_criteria(
          "http://rdf.healthit.gov/qdm/element#DiagnosisActive",
          { :code => "2.16.840.1.113883.3.666.5.225", :title => "Any diagnosis of this type" },
          {
            :severity => {:code => "2.16.840.1.113883.3.666.5.226", :title => "List of severity codes" },
            :ordinal => {:code => "2.16.840.1.113883.3.666.5.227", :title => "List of ordinality" },
            :anatomical_location => {:code => "1.2.3", :title => "List of anatomical locations"},
            :method => {:code => "2.3.4", :title => "List of methods" },
            :facility_location => {:code => "3.4.5", :title => "facility location" }
          },
          { "low" => { "value" => "20150101" }, "high" => { "value" => "20151231" } },
          false, false, '')

        # "SomeTestActiveMedication" => PhEMA::HealthDataStandards::JsonTranslator.data_criteria(
        #   "http://rdf.healthit.gov/qdm/element#MedicationActive",
        #   { :code => "2.16.840.1.113883.3.666.5.225", :title => "Any medication of this type" },
        #   nil,
        #   { "low" => { "value" => "20150101" }, "high" => { "value" => "20151231" } },
        #   false, false, ''
        #   )

        test_med = translator.data_criteria(
           "http://rdf.healthit.gov/qdm/element#MedicationActive",
           { :code => "2.16.840.1.113883.3.666.5.225", :title => "Any medication of this type" },
           nil,
           { "low" => { "value" => "20150101" }, "high" => { "value" => "20151231" } },
           false, false, ''
           )


    #raise "You must specify the JSON file path to convert" unless args.path
    measure = HQMF::Document.from_json({
      "title" => "Test Measure",
      "description" => "This is a test measure",
      "hqmf_version_number" => "v1",  # This is the internal measure version, not a formal CMS version
      "population_criteria" => [],
      "source_data_criteria" => {
        #"TestDiagnosisActive" => test_dx
      },
      "data_criteria" => {
        "TestDiagnosisActive" => test_dx
      },
      "attributes" => [
        translator.measure_score("COHORT"),
        translator.measure_type("OUTCOME"),
        translator.text_attribute("REF", "Reference", "Sample document")
      ],
      "measure_period" => translator.measure_period(nil, nil)
    })
    puts HQMF2::Generator::ModelProcessor.to_hqmf(measure);
  end
end