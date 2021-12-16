module Ead
  module Importer
    extend CommonImporterMethods

    def self.create_solr_docs_from_file_data(filename)
      @solr = Blacklight.default_index.connection
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

      print_message "\nSaving records to solr"
      incoming_ids = []
      map_key_to_class.each do |key, ead_class|
        Array(objects[key]).each do |attributes|
          incoming_ids << attributes[:id]
          if attributes[:dao].present? && ead_class.clean_access_status(attributes['access']) == 'open'
            print_message "\nRetrieving information from Hyrax for #{attributes[:dao]}"
            update_hyrax_visiblity_for_item(attributes[:dao]) 
            attributes = update_solr_docs_from_hyrax(attributes[:dao], attributes)
          end
          @solr.add(ead_class.to_solr(attributes))
        end
        @solr.commit
      end
      delete(incoming_ids)
      errors
    rescue => e
      print_message(" ERROR: Import Aborted")
      errors << filename + ': ' + e.message
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
      counts = {:filename => File.basename(filename,File.extname(filename)), :collections => 0, :sections => 0, :sub_collections => 0, :series => 0, :sub_series => 0, :sub_sub_series => 0, :items => 0, :pieces => 0, :hyax_objects => 0}
      map_key_to_class.each do |key, ead_class|
        Array(objects[key]).each do |attributes|
          incoming_ids << attributes[:id]
          counts[key.to_sym] += 1
          if attributes[:dao].present? && ead_class.clean_access_status(attributes['access']) == 'open'
            counts[:hyrax_objects] += 1
          end
        end
      end
      errors
      counts
    rescue => e
      print_message(" ERROR: Check Aborted")
      errors << filename + ': ' + e.message
    end

    # Delete any orphan solr documents
    # Note: this assumes that the full EAD catalogue is being imported
    #   if a partial catalogue is being imported, all other records will be deleted
    def self.delete(incoming_ids)
      to_delete = deletions(incoming_ids)
      unless to_delete.blank?
        print_message "\nDeleted #{to_delete.join(', ')}"
        @solr.delete_by_id(to_delete)
        @solr.commit
      end
    end
    
    def self.deletions(incoming_ids)
      return if incoming_ids.blank?
      id_base = incoming_ids.first.split('/').first.gsub(' ', '-')
      existing_ids(id_base).map { | existing | existing['id'] if incoming_ids.include?(existing['reference_no_ssi']) == false }.compact!
    end
    
    def self.existing_ids(id_base)
      @solr.get('select', params: {
        q: "id:#{id_base}", 
        fl: 'id,reference_no_ssi',
        rows: 1000
      })['response']['docs']
    end
    
    def self.update_hyrax_visiblity_for_item(dao_id)
      resp = hyrax_app.post do |req|
        req.url "/concern/digital_archival_objects/#{dao_id}/visibility"
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.body = update_hyrax_visiblity_body.to_json
      end
      if resp.status != 200
        print_message("ERROR updating #{dao_id} in Hyrax: #{resp.body}") 
      else
        print_message "\nUpdating visibility in Hyrax for #{dao_id}; response: #{resp.body}" 
      end
      rescue StandardError => e
        print_message("ERROR updating #{dao_id} in Hyrax: #{e.message}") 
    end
    
    def self.update_hyrax_visiblity_body
      {
        'email' => hyrax_config['hyrax'][Rails.env]['username'],
        'password' => hyrax_config['hyrax'][Rails.env]['password'],
        'visibility' => 'open',
        'cascade' => 'true'
      }
    end

    def self.update_solr_docs_from_hyrax(dao_id, item_attributes)
      item_attributes = add_new_attributes(hyrax_solr.get('select', params: {
        q: '*:*', 
        fq: ["{!join from=file_set_ids_ssim to=id}id:#{dao_id}", '!label_tesim:"metadata.json"'],
        fl: 'id,sip_file_name_tesim,label_ssi,mime_type_ssi,file_size_lts,all_text_ts',
        rows: 1000}), item_attributes)
    end
    
    def self.add_new_attributes(solr_result, item_attributes)
      if solr_result['response']['numFound'] == 0
        item_attributes
      else
        item_attributes[:extracted_text] = []
        solr_result['response']['docs'].each do | fs |
          item_attributes[:extracted_text] << fs['all_text_ts'] if fs['all_text_ts']
          @solr.add(file_set(fs, item_attributes[:id]))
        end
        item_attributes[:file_set_ids] = solr_result['response']['docs'].collect {|f| f['id'] }
        # Used for the availability facet
        item_attributes[:online] ='Not Available Online'
        item_attributes[:online] ='Available Online' unless item_attributes[:file_set_ids].blank?
        item_attributes
      end
    end
    
    def self.file_set(attributes, item_id)
      {
        'type_ssi' => 'FileSet',
        'id' => attributes['id'],
        'file_name_tesim' => file_name(attributes),
        'file_size_lts' => attributes['file_size_lts'],
        'mime_type_ssi' => attributes['mime_type_ssi'],
        'in_reference_no_ssi' => item_id
      }
    end
    
    def self.file_name(attributes)
      if attributes['sip_file_name_tesim'].blank?
        [attributes['label_ssi'].split('-').drop(5).join('-')]
      else
        attributes['sip_file_name_tesim']
      end
    end
    
    def self.hyrax_config
      @hyrax_config ||= YAML.load(ERB.new(File.read("#{Rails.root}/config/hyrax.yml")).result)
      @hyrax_config
    end
    
    def self.hyrax_solr
      solr_url = hyrax_config['solr'][Rails.env]['url']
      @hyrax_solr ||= RSolr.connect :url => solr_url
    end
    
    def self.hyrax_app
      @hyrax_app ||= Faraday.new(url: hyrax_config['hyrax'][Rails.env]['url']) do |faraday|
          faraday.adapter :net_http
          # @todo REMOVE ONCE SSL IN PLACE
          faraday.ssl[:verify] = false
          faraday.ssl[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
      end
    end

  end
end
