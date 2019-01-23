require 'spec_helper'
require_relative '../../../lib/import/ead'

describe Ead::Piece do
  let(:id) { 'U DAR/x1/1/51.1/a' }
  let(:formatted_id) { 'U-DAR-x1-1-51.1-a' }
  let(:sortable_id) { 'U DAR/x1/000001/000051.1/a' }
  let(:title) { ['title 1', 'title 2'] }
  let(:repo) { 'Hull University Archives' }
  let(:extent) { ['6 items', '1 volume'] }
  let(:access) { ['<p>acc 1</p>' '<p>acc 2</p>'] }
  let(:desc) { ['<p>desc 1</p>' '<p>desc 2</p>'] }
  let(:dates) { ['1932-1938'] }
  let(:dates_normal) { '1940-1942' }

  let(:collection_id) { 'U DDH' }
  let(:formatted_collection_id) { 'U-DDH' }
  let(:collection_title) { 'Papers of Denzil Dean Harber' }

  let(:sub_collection_title) { 'Sub Coll 1' }
  let(:series_title) { 'General Files' }
  let(:sub_series_title) { 'Sub Series 1' }

  let(:item_id) { 'U DAR/x1/1/51.1' }
  let(:formatted_item_id) { 'U-DAR-x1-1-51.1' }
  let(:item_title) { 'File. Shaw, George Bernard' }

  let(:attrs) {{ id: id, title: title, repository: repo,
                 extent: extent, access: access,
                 description: desc, dates: dates,
                 dates_normal: dates_normal,
                 collection_id: collection_id,
                 collection_title: collection_title,
                 sub_collection_title: sub_collection_title,
                 series_title: series_title,
                 sub_series_title: sub_series_title,
                 item_id: item_id,
                 item_title: item_title
  }}

  describe '.to_solr' do
    it 'formats the IDs' do
      solr_fields = Ead::Piece.to_solr(attrs)

      expect(solr_fields['id']).to eq formatted_id
      expect(solr_fields['item_id_ssi']).to eq formatted_item_id
      expect(solr_fields['collection_id_ssi']).to eq formatted_collection_id
    end

    it 'converts attributes to a hash of solr fields' do
      solr_fields = Ead::Piece.to_solr(attrs)

      # We want Pieces to behave exactly like Items for
      # format faceting and display.
      expect(solr_fields['format_ssi']).to eq 'Archive Item'
      expect(solr_fields['display_title_ss']).to eq "#{title.first}"

      expect(solr_fields['type_ssi']).to eq 'piece'
      expect(solr_fields['reference_no_ssi']).to eq id
      expect(solr_fields['reference_no_ssort']).to eq sortable_id
      expect(solr_fields['title_tesim']).to eq title
      expect(solr_fields['title_ssi']).to eq title.first
      expect(solr_fields['repository_ssi']).to eq repo
      expect(solr_fields['extent_ssm']).to eq extent
      expect(solr_fields['access_ssim']).to eq access
      expect(solr_fields['description_tesim']).to eq desc
      expect(solr_fields['dates_ssim']).to eq dates.first
      expect(solr_fields['dates_isim']).to eq [1940, 1941, 1942]
      expect(solr_fields['date_ssi']).to eq 1940

      expect(solr_fields['collection_title_ss']).to eq collection_title
      expect(solr_fields['sub_collection_title_ss']).to eq sub_collection_title
      expect(solr_fields['series_title_ss']).to eq series_title
      expect(solr_fields['sub_series_title_ss']).to eq sub_series_title
      expect(solr_fields['item_title_ss']).to eq item_title
    end

    it 'handles unknown dates' do
      unknowns = { dates_normal: '0000-0000', dates: 'n.d.' }
      solr_fields = Ead::Piece.to_solr(unknowns)
      expect(solr_fields['dates_ssim']).to eq 'unknown'
      expect(solr_fields['dates_isim']).to eq nil
    end
  end
end
