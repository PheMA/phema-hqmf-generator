require 'pathname'
require 'fileutils'
require 'json'
require 'health-data-standards'
require 'hqmf-parser'
require_relative "../phema-hqmf-generator"

namespace :phema do

  desc 'Convert a PhEMA JSON file to another format'
  task :generate, [:path,:format] do |t, args|
    raise "You must specify the JSON file to convert" unless args.path
    raise "Please specify the output format (hds or hqmf)" unless args.format

    contents = File.open(args.path).read

    translator = PhEMA::Phenotype::JsonTranslator.new
    if args.format == 'hds'
      puts translator.to_hds_json(contents)
    elsif args.format == 'hqmf'
      puts translator.to_hqmf(contents)
    end
  end
end

    # translator = PhEMA::HealthDataStandards::JsonTranslator.new

    # test_dx_name = translator.generate_entity_name("http://rdf.healthit.gov/qdm/element#DiagnosisActive",
    #   "Any diagnosis of this type")
    # test_dx = translator.data_criteria(
    #   "http://rdf.healthit.gov/qdm/element#DiagnosisActive",
    #   { :code => "2.16.840.1.113883.3.666.5.225", :title => "Any diagnosis of this type" },
    #   {
    #     :severity => {:code => "2.16.840.1.113883.3.666.5.226", :title => "List of severity codes" },
    #     :ordinal => {:code => "2.16.840.1.113883.3.666.5.227", :title => "List of ordinality" },
    #     :anatomical_location => {:code => "1.2.3", :title => "List of anatomical locations"},
    #     :method => {:code => "2.3.4", :title => "List of methods" },
    #     :facility_location => {:code => "3.4.5", :title => "facility location" }
    #   },
    #   { "low" => { "value" => "20150101" }, "high" => { "value" => "20151231" } },
    #   false, false, '')

    # test_med_name = translator.generate_entity_name("http://rdf.healthit.gov/qdm/element#MedicationActive",
    #   "Any medication of this type")
    # test_med = translator.data_criteria(
    #    "http://rdf.healthit.gov/qdm/element#MedicationActive",
    #    { :code => "2.16.840.1.113883.3.666.5.225", :title => "Any medication of this type" },
    #    nil,
    #    { "low" => { "value" => "20150101" }, "high" => { "value" => "20151231" } },
    #    false, false, ''
    #    )


    # #raise "You must specify the JSON file path to convert" unless args.path
    # measure = HQMF::Document.from_json({
    #   "title" => "Test Measure",
    #   "description" => "This is a test measure",
    #   "hqmf_version_number" => "v1",  # This is the internal measure version, not a formal CMS version
    #   "population_criteria" => [],
    #   "source_data_criteria" => {
    #     test_dx_name => test_dx,
    #     test_med_name => test_med
    #   },
    #   "data_criteria" => {
    #     test_dx_name => test_dx,
    #     test_med_name => test_med
    #   },
    #   "attributes" => [
    #     translator.measure_score("COHORT"),
    #     translator.measure_type("OUTCOME"),
    #     translator.text_attribute("REF", "Reference", "Sample document")
    #   ],
    #   "measure_period" => translator.measure_period(nil, nil),
    #   "population_criteria" => {
    #     "IPP" => { "type" => "IPP", "title" => "Initial Patient Population",
    #       "conjunction_code" => "allFalse",
    #       "preconditions" => [
    #         { "id" => 10, "reference" => test_dx_name },
    #         { "id" => 11, "reference" => test_med_name }
    #       ]
    #     }
    #   }
    # })
    # puts HQMF2::Generator::ModelProcessor.to_hqmf(measure);
