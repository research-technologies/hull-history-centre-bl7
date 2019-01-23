require_relative 'generic_record'

module Ead
  class Series < GenericRecord
    class << self

      def root_xpath
        'c[@level = "series"]'
      end

      def sub_collection_xpath
          "ancestor::#{Ead::SubCollection.root_xpath}[1]"
      end

      # Map the name of the field to its xpath within the EAD xml
      def fields_map
        super.merge({
          sub_collection_title: "#{sub_collection_xpath}/#{Ead::SubCollection.fields_map[:title]}",
          sub_collection_id: "#{sub_collection_xpath}/#{Ead::SubCollection.fields_map[:id]}"  
        })
      end

      def to_solr(attributes)
          super.merge({
            'type_ssi' => 'series',
            'display_title_ss' => display_title(attributes[:title]),
            'sub_collection_id_ssi' => format_id(attributes[:sub_collection_id]),
            'sub_collection_title_ss' => attributes[:sub_collection_title],
          })
        end

    end
  end
end
