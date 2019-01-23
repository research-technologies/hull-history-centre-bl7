require_relative 'item'

module Ead
  class Piece < Item
    class << self

      def root_xpath
        'c[@otherlevel = "Piece"]'
      end

      # The xpath to the parent Item that the Piece belongs to
      # (relative path from the Piece node)
      def item_xpath
        "ancestor::#{Ead::Item.root_xpath}[1]"
      end

      # Map the name of the field to its xpath within the EAD xml
      def fields_map
        super.merge({
          item_id: "#{item_xpath}/#{Ead::Item.fields_map[:id]}",
          item_title: "#{item_xpath}/#{Ead::Item.fields_map[:title]}",
        })
      end

      def to_solr(attributes)
        super.merge({
          'type_ssi' => 'piece',
          'item_id_ssi' => format_id(attributes[:item_id]),
          'item_title_ss' => attributes[:item_title]
        })
      end

    end
  end
end
