module Sirsi
  module Importer
    extend CommonImporterMethods

    def self.create_solr_docs_from_file_data(filename)
      solr = Blacklight.default_index.connection
      errors = []
      objects = Sirsi::Parser.parse(filename)
      Array(objects[:library_records]).each do |attributes|
        solr.add(Sirsi::LibraryRecord.to_solr(attributes))
      end
      print_message "\nSaving records to solr"
      solr.commit
      errors
    rescue => e
      print_message(" ERROR: Import Aborted")
      errors << filename + ': ' + e.message
    end

    def self.check_file_data(filename)
      objects = Sirsi::Parser.parse(filename)
      errors=[]
      counts = {}

      Array(objects[:library_records]).each do |attributes|
         if counts[attributes[:format]].nil? 
             counts[attributes[:format]] =0
         end
         counts[attributes[:format]]+=1
      end
      counts
    rescue => e
      print_message(" ERROR: Check Aborted")
      errors << filename + ': ' + e.message
    end
  end
end
