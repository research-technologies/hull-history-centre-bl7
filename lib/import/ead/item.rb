require_relative 'generic_record'

module Ead
  class Item < GenericRecord

    class << self

      def root_xpath
        "c[#{xpath_insensitive_equals('otherlevel','item')} or #{xpath_insensitive_equals('level','item')}]"
      end

      def section_xpath
        "ancestor::#{Ead::Section.root_xpath}[1]"
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

      def sub_sub_series_xpath
        "ancestor::#{Ead::SubSubSeries.root_xpath}[1]"
      end

      # Map the name of the field to its xpath within the EAD xml
      def fields_map
        super.merge({
          access_status: 'accessrestrict[@type="status"]',
          sub_collection_title: "#{sub_collection_xpath}/#{Ead::SubCollection.fields_map[:title]}",
          sub_collection_id: "#{sub_collection_xpath}/#{Ead::SubCollection.fields_map[:id]}",
          section_title: "#{section_xpath}/#{Ead::Section.fields_map[:title]}",
          section_id: "#{section_xpath}/#{Ead::Section.fields_map[:id]}",
          series_title: "#{series_xpath}/#{Ead::Series.fields_map[:title]}",
          series_id: "#{series_xpath}/#{Ead::Series.fields_map[:id]}",
          sub_series_title: "#{sub_series_xpath}/#{Ead::SubSeries.fields_map[:title]}",
          sub_series_id: "#{sub_series_xpath}/#{Ead::SubSeries.fields_map[:id]}",
          sub_sub_series_title: "#{sub_sub_series_xpath}/#{Ead::SubSubSeries.fields_map[:title]}",
          sub_sub_series_id: "#{sub_sub_series_xpath}/#{Ead::SubSubSeries.fields_map[:id]}"

        })
      end

      def to_solr(attributes)
        super.merge({
          'reference_no_ssi' => attributes[:id],
          'reference_no_search' => attributes[:id],
          'type_ssi' => 'item',
          'format_ssi' => 'Archive Item',
          'display_title_ss' => display_title(attributes[:title]),
          'access_status_ssi' => clean_access_status(attributes[:access_status]),
          'sub_collection_id_ssi' => format_id(attributes[:sub_collection_id]),
          'sub_collection_title_ss' => attributes[:sub_collection_title],
          'section_id_ssi' => format_id(attributes[:section_id]),
          'section_title_ss' => attributes[:section_title],
          'series_title_ss' => attributes[:series_title],
          'series_id_ssi' => format_id(attributes[:series_id]),
          'sub_series_title_ss' => attributes[:sub_series_title],
          'sub_series_id_ssi' => format_id(attributes[:sub_series_id]),
          'sub_sub_series_title_ss' => attributes[:sub_sub_series_title],
          'sub_sub_series_id_ssi' => format_id(attributes[:sub_sub_series_id])
        })
      end

      def clean_access_status(access)
        access.to_s.downcase.match(/closed/) ? "closed" : "open"
      end

    end
  end
end
