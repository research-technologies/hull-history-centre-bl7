module Ead
  class GenericRecord
      extend ::DateFormatter
      extend ::IdFormatter

      class << self

        def root_xpath
          raise  "root_xpath should be defined in the subclass"
        end

        # The xpath to the collection that the item belongs to
        # (relative path from the item node)
        def collection_xpath
          "ancestor::#{Ead::Collection.root_xpath}[1]"
        end

        # Map the name of the field to its xpath within the EAD xml
        def fields_map
          {
            id: 'did/unitid[@label = "Reference"]',
            title: 'did/unittitle',
            repository: 'did/repository',
            extent: 'did/physdesc/extent',
            access: 'accessrestrict[not(@type="status")]',
            description: 'scopecontent',
            dates: 'did/unitdate',
            language: 'did/langmaterial/language',
            dates_normal: 'did/unitdate/@normal',
            collection_id: "#{collection_xpath}/#{Ead::Collection.fields_map[:id]}",
            collection_title: "#{collection_xpath}/#{Ead::Collection.fields_map[:title]}",
#            dao: 'did/dao/@entityref'
            #according to ead exported from CLAM this is where we find the dao ref
            dao: 'odd/daogrp/daoloc/@href'
          }
        end

        def to_solr(attributes)
          {
            'id' => format_id(attributes[:id]),
            'reference_no_ssi' => attributes[:id],
            'reference_no_ssort' => sortable_id(attributes[:id]),
            'reference_no_search' => attributes[:id],
            'type_ssi' => 'generic_record',
            'title_tesim' => attributes[:title],
            'title_ssi' => Array(attributes[:title]).first,
            'display_title_ss' => attributes[:title],
            'repository_ssi' => attributes[:repository],
            'extent_ssm' => attributes[:extent],
            'access_ssim' => attributes[:access],
            'language_ssim' => attributes[:language],
            'description_tesim' => attributes[:description],
            'dates_ssim' => standardized_dates(attributes[:dates]),
            'dates_isim' => expand_dates(attributes[:dates_normal]),
            'date_ssi' => sortable_date(attributes[:dates_normal]),
            'collection_id_ssi' => format_id(attributes[:collection_id]),
            'collection_title_ss' => attributes[:collection_title],
            'dao_ssi' => attributes[:dao],
            'all_text_timv' => attributes[:extracted_text],
            'file_set_ids_ssim' => attributes[:file_set_ids],
            'online_ssi' => attributes[:online],
          }
        end

        def display_title(title)
          "#{Array(title).first}"
        end

        # using xpath 1.0 no lower-case available so lets use this curious technique
        def xpath_insensitive_equals(field,string)
          "translate(@#{field}, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = '#{string}'"
        end

      end

  end
end
