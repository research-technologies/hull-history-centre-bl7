require 'net/http'
require 'net/https' # for openssl
require 'naturally'

module Analyser
  extend CommonImporterMethods

  def self.get_solr_ref_nos
    solr_cache = '/var/tmp/solr_ref_nos'
    if ! File.exist?(solr_cache)
#      file = File.open(solr_cache, 'w')
 #     get_solr_docs.each{|doc| file.write("#{doc["reference_no_ssi"]}\n") }     
      CSV.open(solr_cache, "wb") {|csv| get_solr_docs.each {|doc| csv << [doc["reference_no_ssi"], doc["title_tesim"]&.first] } }
    end
    @solr_ref_nos = CSV.read(solr_cache)
#    @solr_ref_nos = File.readlines(solr_cache).map(&:chomp)
  end 

  def self.get_solr_docs
    @solr = Blacklight.default_index.connection
    # sort natuallyy with a solr param surely better!?
    Naturally.sort @solr.get('select', params: {
      q: "id:*", 
      fl: 'reference_no_ssi,title_tesim',
      rows: 500000,
    })['response']['docs']
  end

  def self.check_file_data(filename)
    errors = []
    objects = Ead::Parser.parse(filename)
    map_key_to_class = { collections: Ead::Collection,
                         sub_collections:  Ead::SubCollection,
                         items:            Ead::Item,
                         pieces:           Ead::Piece,
                         series:           Ead::Series,
                         sub_series:       Ead::SubSeries,
                         sub_sub_series:   Ead::SubSubSeries,
                         sections:         Ead::Section
                      }
    incoming_ids = []
    map_key_to_class.each do |key, ead_class|
      Array(objects[key]).each do |attributes|

        info = {:source => filename,
                :ead_class => key.to_s.singularize.to_sym,
                :title => attributes[:title] }

        incoming_ids << attributes[:id]
        if attributes[:dao].present? && ead_class.clean_access_status(attributes[:access]) == 'open'
          info[:hyrax_objects] += 1
        end

        id = attributes[:id].to_sym
        freq = @analyse_totals[id].is_a?(Array) ? @analyse_totals[id].first : 0
        title = @analyse_totals[id].is_a?(Array) ?  @analyse_totals[id].second : nil

        @analyse_totals[id] = [freq, title, info.values].flatten!

      end
    end
    errors
#    rescue => e
#      print_message(" ERROR: Check Aborted")
#      errors << filename + ': ' + e.message
  end

  def self.check_blacklight(id)
    @solr_ref_nos.include?(id)
  end

end

