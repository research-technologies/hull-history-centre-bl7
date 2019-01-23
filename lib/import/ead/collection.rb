module Ead
  module Collection
    extend ::DateFormatter
    extend ::IdFormatter

    class << self

      def root_xpath
        'archdesc'
      end

      # Map the name of the field to its xpath within the EAD xml
      def fields_map
        {
          id: 'did/unitid[@label = "Reference"]',
          title: 'did/unittitle',
          repository: "did/repository",
          dates: 'did/unitdate',
          dates_normal: 'did/unitdate/@normal',
          extent: 'did/physdesc/extent',
          access: 'accessrestrict[not(@type="status")]',
          custodial_history: 'custodhist',
          language: 'did/langmaterial/language',
          biog_hist: 'bioghist',
          description: 'scopecontent',
          arrangement: 'arrangement',
          related: 'relatedmaterial',
          pub_notes: 'bibliography/bibref',
          copyright: 'userestrict[@encodinganalog="Calm Copyright"]'
        }
      end

      def to_solr(attributes)
        {
          'id' => format_id(attributes[:id]),
          'reference_no_ssi' => attributes[:id],
          'reference_no_ssort' => sortable_id(attributes[:id]),
          'type_ssi' => 'collection',
          'format_ssi' => 'Archive Collection',
          'title_tesim' => attributes[:title],
          'title_ssi' => Array(attributes[:title]).first,
          'display_title_ss' => display_title(attributes[:title]),
          'repository_ssi' => attributes[:repository],
          'dates_ssim' => standardized_dates(attributes[:dates]),
          'dates_isim' => expand_dates(attributes[:dates_normal]),
          'date_ssi' => sortable_date(attributes[:dates_normal]),
          'extent_ssm' => attributes[:extent],
          'access_ssim' => attributes[:access],
          'custodial_history_ssim' => attributes[:custodial_history],
          'language_ssim' => attributes[:language],
          'biog_hist_ssm' => attributes[:biog_hist],
          'description_tesim' => attributes[:description],
          'arrangement_ssm' => attributes[:arrangement],
          'related_ssm' => attributes[:related],
          'pub_notes_ssm' => break_lines(attributes[:pub_notes]),
          'copyright_ssm' => attributes[:copyright]
        }
      end

      def display_title(title)
        "#{Array(title).first}"
      end

      def break_lines(raw_data)
        return nil if raw_data.nil?
        raw_data.gsub("\n", '<br />')
      end

    end
  end
end
