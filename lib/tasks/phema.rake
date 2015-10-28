require 'pathname'
require 'fileutils'
require 'json'
require 'health-data-standards'
require 'hqmf-parser'
require_relative "../phema-hqmf-generator"

namespace :phema do

  desc 'Convert a PhEMA JSON file to another format'
  task :generate, [:input,:output,:format] do |t, args|
    raise "You must specify the path to the JSON file you wish to convert" unless args.input
    raise "Please specify the output format (hds or hqmf)" unless args.format
    args.with_defaults(:output => nil)

    contents = File.open(args.input).read

    translator = PhEMA::Phenotype::JsonTranslator.new
    result = ""
    if args.format == 'hds'
      result = translator.to_hds_json(contents)
    elsif args.format == 'hqmf'
      result = translator.to_hqmf(contents)
    end

    # If no path is specified to write to, we'll just print to the console
    if (args.output.empty?)
      puts result
    else
      File.open(args.output, 'w') { |file| file.write(result) }
    end
  end
end