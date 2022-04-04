require_relative 'generic_record'

module Ead
  class SubSeries < GenericRecord
      class << self

        def root_xpath
          'c[@otherlevel="SubSeries"]'
        end

        def section_xpath
          "ancestor::#{Ead::Section.root_xpath}[1]"
        end

        def sub_collection_xpath
          "ancestor::#{Ead::SubCollection.root_xpath}[1]"
        end

        def section_xpath
          "ancestor::#{Ead::Section.root_xpath}[1]"
        end

        def series_xpath
          "ancestor::#{Ead::Series.root_xpath}[1]"
        end

        # Map the name of the field to its xpath within the EAD xml
        def fields_map
          super.merge({
            sub_collection_title: "#{sub_collection_xpath}/#{Ead::SubCollection.fields_map[:title]}",
            sub_collection_id: "#{sub_collection_xpath}/#{Ead::SubCollection.fields_map[:id]}",    
            section_title: "#{section_xpath}/#{Ead::Section.fields_map[:title]}",
            section_id: "#{section_xpath}/#{Ead::Section.fields_map[:id]}",    
            section_title: "#{section_xpath}/#{Ead::Section.fields_map[:title]}",
            section_id: "#{section_xpath}/#{Ead::Section.fields_map[:id]}",    
            series_title: "#{series_xpath}/#{Ead::Series.fields_map[:title]}",
            series_id: "#{series_xpath}/#{Ead::Series.fields_map[:id]}"
          })
        end

        def to_solr(attributes)
          super.merge({
            'type_ssi' => 'subseries',
            'display_title_ss' => display_title(attributes[:title]),
            'sub_collection_id_ssi' => format_id(attributes[:sub_collection_id]),
            'sub_collection_title_ss' => attributes[:sub_collection_title],
            'section_id_ssi' => format_id(attributes[:section_id]),
            'section_title_ss' => attributes[:section_title],
            'section_id_ssi' => format_id(attributes[:section_id]),
            'section_title_ss' => attributes[:section_title],
            'series_title_ss' => attributes[:series_title],
            'series_id_ssi' => format_id(attributes[:series_id])
          })
        end

      end

  end
end
