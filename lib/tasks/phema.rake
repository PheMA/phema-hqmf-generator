require 'pathname'
require 'fileutils'
require 'json'
require 'health-data-standards'
require 'hqmf-parser'
require 'rubygems'
require 'zip/zip'
require_relative "../phema-hqmf-generator"

namespace :phema do

  desc 'Convert a PhEMA JSON file to another format'
  task :generate, [:input,:output,:format,:export_value_sets] do |t, args|
    raise "You must specify the path to the JSON file you wish to convert" unless args.input
    raise "Please specify the output format (hds or hqmf)" unless args.format
    args.with_defaults({:output => nil, :export_value_sets => false})

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
      # Output is going to specify a zip file, and we want to name the files that are going into it
      # based on the base name.  We'll grab that now
      base_file_name = File.join(File.dirname(args.output), File.basename(args.output, '.*'))
      result_file_name = base_file_name + (args.format == 'hds' ? '.json' : '.xml')
      csv_file_name = base_file_name + '.csv'

      zip_folder = File.dirname(args.output)
      zip_files = []

      # Create the output files
      begin
        File.open(result_file_name, 'w') { |file| file.write(result) }
        zip_files << result_file_name
      rescue
      end

      begin
        File.open(csv_file_name, 'w') { |file| file.write(translator.export_value_sets) } if args.export_value_sets
        zip_files << csv_file_name
      rescue
      end

      # Clean up the zip file if one already exists with the name
      File.delete(args.output) if File.exist?(args.output)

      # Now define and create the zip file
      Zip::ZipFile.open(args.output, Zip::ZipFile::CREATE) do |zipfile|
        zip_files.each do |filename|
          zipfile.add(File.basename(filename), filename)
        end
      end
    end
  end
end