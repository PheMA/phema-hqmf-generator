require 'pathname'
require 'fileutils'
require 'json'
require 'health-data-standards'
require 'hqmf-parser'

namespace :phema do

  desc 'Parse all xml files to JSON and save them to ./tmp'
  task :generate, [:path] do |t, args|

    #raise "You must specify the JSON file path to convert" unless args.path
    measure = HQMF::Document.from_json({
      "population_criteria" => [],
      "data_criteria" => [],
      "source_data_criteria" => [],
      "attributes" => [],
      "measure_period" => {
        "low" => {
          "value" => "19000101"
        },
        "high" => {
          "value" => "20020101"
        }
      }
    })
    puts HQMF2::Generator::ModelProcessor.to_hqmf(measure);
  end
end