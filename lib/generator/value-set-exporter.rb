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
          # Get the value set (container) definition
          value_set = HealthDataStandards::SVS::ValueSet.new
          response = RestClient.get("#{@value_set_services[:phema][:repository]}valueset/#{oid}?format=json", {accept: :json})
          if response.code == 200
            cts2_value_set = JSON.parse(response.body)
            value_set.display_name = cts2_value_set["ValueSetCatalogEntryMsg"]["valueSetCatalogEntry"]["formalName"]
            value_set.oid = oid
          end

          # Get the value set concepts definition
          response = RestClient.get("#{@value_set_services[:phema][:repository]}valueset/#{oid}/resolution?format=json", {accept: :json})
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

          value_sets << value_set
        end

        value_sets
      end
    end
  end
end
