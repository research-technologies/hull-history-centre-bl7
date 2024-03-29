require_relative 'generic_record'

module Ead
  class SubCollection < GenericRecord
    class << self 

      def root_xpath
        "c[#{xpath_insensitive_equals('otherlevel','subcollection')} or #{xpath_insensitive_equals('level','subcollection')}]"
      end

      def to_solr(attributes)
          super.merge({
            'type_ssi' => 'subcollection',
            'display_title_ss' => display_title(attributes[:title]),
            'sub_collection_title_ss' => attributes[:sub_collection_title],
          })
        end

    end
  end
end
