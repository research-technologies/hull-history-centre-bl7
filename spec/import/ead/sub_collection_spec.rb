require 'spec_helper'
require_relative '../../../lib/import/ead'

describe Ead::SubCollection do

  describe '.to_solr' do    
    let(:id) { 'U DAR/x2' }
    let(:formatted_id) { 'U-DAR-x2' }
    let(:title) { ['Second Deposit'] }
    let(:dates) { ['1979 - 1980'] }
    let(:dates_normal) { '1979-1980' }
    let(:extent) { ['8 items']}
    let(:repo) { 'Hull University Archives' }
    let(:desc) { '<p>Contents:</p><p></p><p>U DAR2/1 Correspondence, 1919 - 1973</p><p>U DAR2/2  Diaries and memoirs, 1967 - 1979</p><p>U DAR2/3 &apos;A history of the Miners&apos;Federation of Great Britain&apos; (1949 - 1979), 1873 - 1961</p><p>U DAR2/4  &apos;A history of the Scottish miners&apos; (1955), 1880 - 1958</p><p>U DAR2/5 &apos;The South Wales Miners: a history of the South Wales Miners&apos;Federation&apos; (1967 - 1973), 1899 - 1972</p><p>U DAR2/6 &apos;William Morris: the man and the myth&apos; (1964), 1885 - 1964</p><p>U DAR2/7 &apos;The impact of the Russian Revolution in Britain&apos; (1967), 1966 - 1967</p><p>U DAR2/8  Other works, 1919 - 1967</p><p>U DAR2/9 Olive E Arnot, 1946 - 1963</p><p>U DAR2/10  Communist Party of Great Britain, 1935 - 1963</p><p>U DAR2/11 Marx Memorial Library and Workers&apos; School, 1843 - 1967</p><p>U DAR2/12 William Morris Society, 1949 - 1970</p><p>U DAR2/13 Miscellaneous, 1891 - 1975</p>'}
    let(:access) {'<p>Access will be granted to any accredited reader</p>' }
    let(:collection_id) { 'C DBCO' }
    let(:formatted_collection_id) { 'C-DBCO' }
    let(:collection_title) { 'Records of Comet Group PLC (1933-2012)' }

    it 'converts attributes to a hash of solr fields' do
      attributes = { id: id, title: title, repository: repo,
                    extent: extent, access: access, 
                    description: desc, dates: dates,
                    dates_normal: dates_normal,
                    collection_id: collection_id,
                    collection_title: collection_title }

      solr_fields = Ead::SubCollection.to_solr(attributes)

      expect(solr_fields['type_ssi']).to eq 'subcollection'
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
      expect(solr_fields['dates_isim']).to eq [1979, 1980]
      expect(solr_fields['date_ssi']).to eq 1979

      expect(solr_fields['collection_id_ssi']).to eq formatted_collection_id
      expect(solr_fields['collection_title_ss']).to eq collection_title
    end

    it 'handles unknown dates' do
      unknowns = { dates_normal: '0000-0000', dates: 'n.d.' }
      solr_fields = Ead::SubSeries.to_solr(unknowns)
      expect(solr_fields['dates_ssim']).to eq 'unknown'
      expect(solr_fields['dates_isim']).to eq nil
    end

  end
end