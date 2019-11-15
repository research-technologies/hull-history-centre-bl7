require_relative '../concerns/date_formatter'

module Sirsi
  module LibraryRecord
    extend ::DateFormatter

    class << self

      def root_xpath
        'record'
      end

      # Map the name of the field to its xpath within the xml
      def fields_map
        {
          id: 'catalog/catalog_key',
          reference_number: 'catalog/call_number',
          title: 'catalog/marc/marc_field[@tag="245"]',
          format: 'catalog/item_record/cat1',
          subject: 'catalog/marc/marc_field[@tag="650"]',
          subject_600: 'catalog/marc/marc_field[@tag="600"]',
          subject_630: 'catalog/marc/marc_field[@tag="630"]',
          subject_651: 'catalog/marc/marc_field[@tag="651"]',
          author_100: 'catalog/marc/marc_field[@tag="100"]',
          author_110: 'catalog/marc/marc_field[@tag="110"]',
          author_700: 'catalog/marc/marc_field[@tag="700"]',
          author_710: 'catalog/marc/marc_field[@tag="710"]',
          language: 'catalog/marc/marc_field[@tag="546"]',
          publisher: 'catalog/marc/marc_field[@tag="260"]',
          physical_desc: 'catalog/marc/marc_field[@tag="300"]',
          dates: 'catalog/catalog_year_of_pub',
          notes: 'catalog/marc/marc_field[@tag="500"]',
          isbn: 'catalog/marc/marc_field[@tag="020"]',
        }
      end

      def to_solr(attributes)
        {
          'type_ssi' => 'library_record',
          'repository_ssi' => 'Hull Local Studies Library',
          'id' => attributes[:id],
          'reference_no_ssi' => attributes[:reference_number],
          'reference_no_ssort' => attributes[:reference_number],
          'title_tesim' => attributes[:title],
          'title_ssi' => Array(attributes[:title]).first,
          'display_title_ss' => display_title(attributes),
          'format_ssi' => transformed_format(attributes[:format].first),
          'subject_ssim' => attributes[:subject],
          'subject_tesim' => attributes[:subject],
          'personal_subject_ssim' => attributes[:subject_600],
          'personal_subject_tesim' => attributes[:subject_600],
          'corporate_subject_ssim' => attributes[:subject_630],
          'corporate_subject_tesim' => attributes[:subject_630],
          'geographical_subject_ssim' => attributes[:subject_651],
          'geographical_subject_tesim' => attributes[:subject_651],
          'author_tesim' => authors(attributes),
          'author_ssim' => authors(attributes),
          'language_ssim' => attributes[:language],
          'publisher_ssim' => attributes[:publisher],
          'dates_ssim' => standardized_dates(attributes[:dates]),
          'dates_isim' => integer_dates(attributes[:dates]),
          'date_ssi' => sortable_date(attributes[:dates]),
          'physical_description_ssm' => attributes[:physical_desc],
          'notes_ssm' => attributes[:notes],
          'isbn_ssm' => attributes[:isbn]
        }
      end

      def authors(attributes)
        [attributes[:author_100],
         attributes[:author_700],
         attributes[:author_110],
         attributes[:author_710]].flatten
      end

      def transformed_format(raw_data_format)
        data = raw_data_format.upcase if raw_data_format
        format_map.fetch(data, raw_data_format)
      end

      # Keys are how the format appears in the SIRSI xml.
      # Values are how the format appears in blacklight facets.
      def format_map
        {
          "AFHDBK" => 'Book',
          "AFLPPBK" => 'Book',
          "AFLPTHDBK" => 'Book',
          "AFLPTPBK" => 'Book',
          "AFPBK" => 'Book',
          "ANFHBK" => 'Book',
          "ANFLPPBK" => 'Book',
          "ANFLPTHDBK" => 'Book',
          "ANFLPTPBK" => 'Book',
          "ANFPBK" => 'Book',
          "CFHBK" => 'Book',
          "CFPBK" => 'Book',
          "CNFHBK" => 'Book',
          "CNFPBK" => 'Book',
          "LARGEPRINT" => 'Book',
          "MAGAZINE" => 'Book',
          "PICBK" => 'Book',
          "TEENFPBK" => 'Book',

          "AFCAS" => 'Cassette',
          "ANFCAS" => 'Cassette',
          "TKBKADCAS" => 'Cassette',

          "CD" => 'CD/DVD',
          "CDROM" => 'CD/DVD',
          "DVD" => 'CD/DVD',
          "TKBKADCD" => 'CD/DVD',

          "MAP" => 'Map',
          "MICROFORM" => 'Microfilm',
          "NEWSPAPER" => 'Newspaper',
          "PAMPHLARGE" => 'Pamphlet',
          "PAMPHSMALL" => 'Pamphlet',
          "VIDEO" => 'Video'
        }
      end

      def display_title(attributes)
        "#{Array(attributes[:title]).first}"
      end

    end
  end
end
