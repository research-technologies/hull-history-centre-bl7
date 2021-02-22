require 'nokogiri'

module Ead
  module Parser
    class << self

      def parse(file)
        ead_data = File.read(file)
        doc = Nokogiri::XML(ead_data)

        collections = parse_records(doc, Ead::Collection)
        sub_collections = parse_records(doc, Ead::SubCollection)
        items = parse_records(doc, Ead::Item)
        pieces = parse_records(doc, Ead::Piece)
        series = parse_records(doc, Ead::Series)
        sub_series = parse_records(doc, Ead::SubSeries)
        # TODO sub_sub_series (for historical records)
        # TODO section (for historical record)

        if collections.empty? && items.empty? && pieces.empty?
          raise "No records found.  Please check that you have valid XML."
        end

        { collections: collections, sub_collections: sub_collections, items: items, pieces: pieces, series: series, sub_series: sub_series }
      end

      def parse_records(node, record_class)
        nodes = node.xpath("//#{record_class.root_xpath}")
        nodes.map do |item|
          print '.' if verbose
          attrs_for_record(item, record_class)
        end
      end

      # Get all the attributes for a single record
      def attrs_for_record(node, record_class)
        record_class.fields_map.inject({}) do |attrs, (field, xpath)|
          element = node.xpath("./#{xpath}")

          value = if element.children.length > 1
                    element.children.map(&:to_s)
                  else
                    text = element.text
                    text = text.strip if text
                  end
          value = Array(value).map{|e| e.encode('UTF-8') }
          value = value.first if value.length == 1

          attrs = attrs.merge(field => value)
        end
      end

      def verbose
        true
      end

    end
  end
end
