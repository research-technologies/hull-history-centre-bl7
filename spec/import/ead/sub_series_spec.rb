require 'spec_helper'
require_relative '../../../lib/import/ead'

describe Ead::SubSeries do

  describe '.to_solr' do    
    let(:id) { 'C DBCO/1/1' }
    let(:formatted_id) { 'C-DBCO-1-1' }
    let(:title) { ['Comet Radiovision Services Ltd Minute Books'] }
    let(:dates) { ['1972-1988'] }
    let(:dates_normal) { '1972-1975' }
    let(:extent) { ['8 items']}
    let(:repo) { 'Hull University Archives' }
    let(:desc) { '<p>Subseries contains minute books recording ordinary Board meetings of Comet Radiovision Services Limited. Please note that minutes of AGMs can be found under the reference C DBCO/1/3.</p>'}
    let(:access) {'<p>Access will be granted to any accredited reader</p>' }
    let(:collection_id) { 'C DBCO' }
    let(:formatted_collection_id) { 'C-DBCO' }
    let(:sub_collection_id) { 'C DBCOx' }
    let(:formatted_sub_collection_id) { 'C-DBCOx' }
    let(:sub_collection_title) { 'Records A' }
    let(:collection_title) { 'Records of Comet Group PLC (1933-2012)' }
    let(:series_title) { 'Comet Group PLC Minute Books' }
    let(:series_id) { 'C DBCOx/1' }
    let(:formatted_series_id) { 'C-DBCOx-1' }

    it 'converts attributes to a hash of solr fields' do
      attributes = { id: id, title: title, repository: repo,
                    extent: extent, access: access, 
                    description: desc, dates: dates,
                    dates_normal: dates_normal,
                    collection_id: collection_id,
                    collection_title: collection_title,
                    sub_collection_id: sub_collection_id,
                    sub_collection_title: sub_collection_title,
                    series_title: series_title,
                    series_id: series_id }

      solr_fields = Ead::SubSeries.to_solr(attributes)

      expect(solr_fields['type_ssi']).to eq 'subseries'
      expect(solr_fields['id']).to eq formatted_id
      expect(solr_fields['reference_no_ssi']).to eq id
      expect(solr_fields['title_tesim']).to eq title
      expect(solr_fields['title_ssi']).to eq title.first
      expect(solr_fields['display_title_ss']).to eq "#{title.first}"
      expect(solr_fields['repository_ssi']).to eq repo
      # We don't want to index for the facets
      expect(solr_fields['format_ssi']).to eq nil
      expect(solr_fields['extent_ssm']).to eq extent
      expect(solr_fields['access_ssim']).to eq access
      expect(solr_fields['description_tesim']).to eq desc
      expect(solr_fields['dates_ssim']).to eq dates.first
      expect(solr_fields['dates_isim']).to eq [1972, 1973, 1974, 1975]
      expect(solr_fields['date_ssi']).to eq 1972

      expect(solr_fields['collection_id_ssi']).to eq formatted_collection_id
      expect(solr_fields['collection_title_ss']).to eq collection_title
      expect(solr_fields['sub_collection_id_ssi']).to eq formatted_sub_collection_id
      expect(solr_fields['sub_collection_title_ss']).to eq sub_collection_title
      expect(solr_fields['series_title_ss']).to eq series_title
      expect(solr_fields['series_id_ssi']).to eq formatted_series_id
    end

    it 'handles unknown dates' do
      unknowns = { dates_normal: '0000-0000', dates: 'n.d.' }
      solr_fields = Ead::SubSeries.to_solr(unknowns)
      expect(solr_fields['dates_ssim']).to eq 'unknown'
      expect(solr_fields['dates_isim']).to eq nil
    end

  end
end