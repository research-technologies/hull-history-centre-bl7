module Ead
  module Importer
    extend CommonImporterMethods

    def self.create_solr_docs_from_file_data(filename)
      solr = RSolr.connect :url => 'http://localhost:8983/solr/blacklight-core'
      errors = []
      objects = Ead::Parser.parse(filename)

      map_key_to_class = { collections: Ead::Collection,
                           sub_collections:  Ead::SubCollection,
                           items:                  Ead::Item,
                           pieces:                 Ead::Piece,
                           series:                  Ead::Series,
                           sub_series:          Ead::SubSeries }

      print_message "\nSaving records to solr"
      map_key_to_class.each do |key, ead_class|
        Array(objects[key]).each do |attributes|
          solr.add(ead_class.to_solr(attributes))
        end
        solr.commit
      end

      errors
    rescue => e
      print_message(" ERROR: Import Aborted")
      errors << filename + ': ' + e.message
    end

  end
end
