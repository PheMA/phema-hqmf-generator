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
      "source_data_criteria" => [],
      "attributes" => [
        PhEMA::HealthDataStandards::JsonTranslator.measure_score("COHORT"),
        PhEMA::HealthDataStandards::JsonTranslator.attribute("REF", "Sample document")
      ],
      "measure_period" => PhEMA::HealthDataStandards::JsonTranslator.measure_period(nil, nil)
    })
    puts HQMF2::Generator::ModelProcessor.to_hqmf(measure);
  end
end