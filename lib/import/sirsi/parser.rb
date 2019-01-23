require 'nokogiri'

module Sirsi
  module Parser
    class << self

      def parse(file)
        sirsi_data = File.read(file)
        xml = Nokogiri::XML(sirsi_data)
        nodes = xml.xpath("//#{Sirsi::LibraryRecord.root_xpath}")
        records = nodes.map do |record|
          print '.' if verbose
          attrs_for_record(record, Sirsi::LibraryRecord)
        end

        results = { library_records: records }
        if results[:library_records].empty?
          raise "No records found.  Please check that you have valid XML."
        end
        results
      end

      # Get all the attributes for a single record
      def attrs_for_record(node, record_class)
        record_class.fields_map.inject({}) do |attrs, (field, xpath)|
          element = node.xpath("./#{xpath}")

          value = Array(element).inject([]) do |values, element|
            text = element.text
            text = text.strip if text
            values << text
          end

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
