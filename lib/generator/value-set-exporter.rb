require 'json'
require 'rest-client'
require 'health-data-standards'

module PhEMA
  module Phenotype
    # Takes the output of the PhEMA authoring tool (a JSON-based phenotype definition), and identifies
    # all value sets.  It the connects to a CTS2 repository and exports the value set definitions.
    #
    # CTS2 config - a hash of CTS2 configuration details.  This follows how the phema-author tool
    # defines configurations:
    # valueSetServices: { "cts2Key" : { title: "CTS2 Repo Name", repository: "http://url" } }
    class ValueSetExporter
      def initialize(value_set_services)
        @value_set_services = value_set_services
      end

      def export(oid_list)
        value_sets = []
        oid_list.each do |oid|
          @value_set_services.each do |service|
            puts "Searching for #{oid} in #{service[0]}"
            value_set = (service[1][:type] == "fhir" ? export_fhir(service, oid) : export_cts2(service, oid))
            if (value_set.nil?)
              puts "Value set not found"
              next
            else
              puts "Found value set"
              value_sets << value_set
              break
            end
          end
        end

        value_sets
      end

      def export_fhir(service, oid)
        begin
          # Get the value set (container) definition
          value_set = HealthDataStandards::SVS::ValueSet.new
          response = RestClient.get("#{service[1][:repository]}ValueSet/#{oid}", {accept: :json})
          if response.code == 200
            fhir_value_set = JSON.parse(response.body)
            puts response.body
            value_set.display_name = fhir_value_set["name"]
            value_set.oid = oid

            fhir_value_set["compose"]["include"].each do |cs_results|
              cs_results["concept"].each do |entry|
                concept = HealthDataStandards::SVS::Concept.new
                concept.code = entry["code"]
                concept.display_name = entry["display"]
                concept.code_system_name = cs_results["system"]
                concept.code_system = cs_results["system"]
                value_set.concepts << concept
              end
            end
          end

          value_set
        rescue => e
          puts "Error searching for CTS2 value set: #{$!}"
          nil
        end
      end

      def export_cts2(service, oid)
        begin
          # Get the value set (container) definition
          value_set = HealthDataStandards::SVS::ValueSet.new
          response = RestClient.get("#{service[1][:repository]}valueset/#{oid}?format=json", {accept: :json})
          if response.code == 200
            cts2_value_set = JSON.parse(response.body)
            value_set.display_name = cts2_value_set["ValueSetCatalogEntryMsg"]["valueSetCatalogEntry"]["formalName"]
            value_set.oid = oid
          else
            return nil
          end

          # Get the value set concepts definition
          response = RestClient.get("#{service[1][:repository]}valueset/#{oid}/resolution?format=json", {accept: :json})
          if response.code == 200
            cts2_concepts = JSON.parse(response.body)
            cts2_concepts["IteratableResolvedValueSet"]["entry"].each do |entry|
              concept = HealthDataStandards::SVS::Concept.new
              concept.code = entry["name"]
              concept.display_name = entry["designation"]
              concept.code_system_name = entry["namespace"]
              concept.code_system = entry["namespace"]
              value_set.concepts << concept
            end
          end

          value_set
        rescue => e
          puts "Error searching for CTS2 value set: #{$!}"
          nil
        end
      end
    end
  end
end
