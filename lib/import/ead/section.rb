require_relative 'generic_record'

module Ead
  class Section < GenericRecord
    class << self 

      def root_xpath
        'c[@otherlevel="Section"]'
      end

      def to_solr(attributes)
          super.merge({
            'type_ssi' => 'section',
            'display_title_ss' => display_title(attributes[:title]),
            'section_title_ss' => attributes[:section_title],
          })
        end

    end
  end
end
