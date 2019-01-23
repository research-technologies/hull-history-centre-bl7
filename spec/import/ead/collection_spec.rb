require 'spec_helper'
require_relative '../../../lib/import/ead'

describe Ead::Collection do
  describe '.to_solr' do
    let(:id) { 'U DDH' }
    let(:formatted_id) { 'U-DDH' }
    let(:sortable_id) { 'U DDH' }
    let(:title) { 'Papers of Denzil Dean Harber' }
    let(:repo) { 'Hull University Archives' }
    let(:dates) { ['1932-1938'] }
    let(:dates_normal) { '1932-1935' }
    let(:extent) { ['6 items', '1 volume'] }
    let(:access) { ['<p>acc 1</p>' '<p>acc 2</p>'] }
    let(:cust) { ['<p>cust 1</p>' '<p>cust 2</p>'] }
    let(:lang) { 'English' }
    let(:biog) { 'biog' }
    let(:desc) { 'desc' }
    let(:arrange) { ['<p>arr 1</p>' '<p>arr 2</p>'] }
    let(:rel) { ['<p>rel 1</p>' '<p>rel 2</p>'] }
    let(:pub_notes) { "pub notes 1\npub notes 2" }
    let(:pub_notes_trans) { "pub notes 1<br />pub notes 2" }
    let(:copyright) { 'Julian Harber' }

    let(:attributes) {{ id: id, title: title, repository: repo,
                     dates: dates, dates_normal: dates_normal,
                     extent: extent, access: access,
                     custodial_history: cust, language: lang,
                     biog_hist: biog, description: desc,
                     arrangement: arrange, related: rel,
                     pub_notes: pub_notes, copyright: copyright }}

    it 'converts attributes to a hash of solr fields' do
      solr_fields = Ead::Collection.to_solr(attributes)
      expect(solr_fields['type_ssi']).to eq 'collection'
      expect(solr_fields['id']).to eq formatted_id
      expect(solr_fields['reference_no_ssi']).to eq id
      expect(solr_fields['reference_no_ssort']).to eq sortable_id
      expect(solr_fields['title_tesim']).to eq title
      expect(solr_fields['title_ssi']).to eq title
      expect(solr_fields['display_title_ss']).to eq "#{title}"
      expect(solr_fields['repository_ssi']).to eq repo
      expect(solr_fields['format_ssi']).to eq 'Archive Collection'
      expect(solr_fields['dates_ssim']).to eq dates.first
      expect(solr_fields['dates_isim']).to eq [1932, 1933, 1934, 1935]
      expect(solr_fields['date_ssi']).to eq 1932
      expect(solr_fields['extent_ssm']).to eq extent
      expect(solr_fields['access_ssim']).to eq access
      expect(solr_fields['custodial_history_ssim']).to eq cust
      expect(solr_fields['language_ssim']).to eq lang
      expect(solr_fields['biog_hist_ssm']).to eq biog
      expect(solr_fields['description_tesim']).to eq desc
      expect(solr_fields['arrangement_ssm']).to eq arrange
      expect(solr_fields['related_ssm']).to eq rel
      expect(solr_fields['pub_notes_ssm']).to eq pub_notes_trans
      expect(solr_fields['copyright_ssm']).to eq copyright
    end

    it 'handles unknown dates' do
      unknowns = { dates_normal: '0000-0000', dates: 'n.d.' }
      solr_fields = Ead::Collection.to_solr(unknowns)
      expect(solr_fields['dates_ssim']).to eq 'unknown'
      expect(solr_fields['dates_isim']).to eq nil
    end
  end
end
