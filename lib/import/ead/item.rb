require_relative 'generic_record'

module Ead
  class Item < GenericRecord

    class << self

      def root_xpath
        'c[@level = "item"]'
      end

      def sub_collection_xpath
        "ancestor::#{Ead::SubCollection.root_xpath}[1]"
      end

      def series_xpath
        "ancestor::#{Ead::Series.root_xpath}[1]"
      end

      def sub_series_xpath
        "ancestor::#{Ead::SubSeries.root_xpath}[1]"
      end

      # Map the name of the field to its xpath within the EAD xml
      def fields_map
        super.merge({
          access_status: 'accessrestrict[@type="status"]',
          sub_collection_title: "#{sub_collection_xpath}/#{Ead::SubCollection.fields_map[:title]}",
          sub_collection_id: "#{sub_collection_xpath}/#{Ead::SubCollection.fields_map[:id]}",
          series_title: "#{series_xpath}/#{Ead::Series.fields_map[:title]}",
          series_id: "#{series_xpath}/#{Ead::Series.fields_map[:id]}",
          sub_series_title: "#{sub_series_xpath}/#{Ead::SubSeries.fields_map[:title]}",
          sub_series_id: "#{sub_series_xpath}/#{Ead::SubSeries.fields_map[:id]}"
        })
      end

      def to_solr(attributes)
        super.merge({
          'reference_no_ssi' => attributes[:id],
          'type_ssi' => 'item',
          'format_ssi' => 'Archive Item',
          'display_title_ss' => display_title(attributes[:title]),
          'access_status_ssi' => clean_access_status(attributes[:access_status]),
          'sub_collection_id_ssi' => format_id(attributes[:sub_collection_id]),
          'sub_collection_title_ss' => attributes[:sub_collection_title],
          'series_title_ss' => attributes[:series_title],
          'series_id_ssi' => format_id(attributes[:series_id]),
          'sub_series_title_ss' => attributes[:sub_series_title],
          'sub_series_id_ssi' => format_id(attributes[:sub_series_id])
        })
      end

      def clean_access_status(access)
        access.to_s.downcase.match(/closed/) ? "closed" : "open"
      end

    end
  end
end
