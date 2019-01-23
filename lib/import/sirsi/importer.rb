module Sirsi
  module Importer
    extend CommonImporterMethods

    def self.create_solr_docs_from_file_data(filename)
      errors = []
      objects = Sirsi::Parser.parse(filename)
      Array(objects[:library_records]).each do |attributes|
        Blacklight.solr.add(Sirsi::LibraryRecord.to_solr(attributes))
      end
      print_message "\nSaving records to solr"
      Blacklight.solr.commit
      errors
    rescue => e
      print_message(" ERROR: Import Aborted")
      errors << filename + ': ' + e.message
    end

  end
end
