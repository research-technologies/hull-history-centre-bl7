require 'rails_helper'
require 'import/ead'

feature 'viewing a record:' do
  let(:sirsi_fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_sirsi_files')) }
  let(:ead_fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_ead_files')) }
  let(:sirsi_single_file) { File.join(sirsi_fixtures_path, 'single_sirsi_record.xml') }
  let(:sirsi_full_file) { File.join(sirsi_fixtures_path, 'full_record_sample.xml') }
  let(:ead_file) { File.join(ead_fixtures_path, 'U_DAR_pruned.xml') }

  context 'sirsi-record' do  
    before do
      Blacklight.solr.delete_by_query('*:*', params: { commit: true })
      allow(Sirsi::Parser).to receive(:verbose) { false }
      allow(Sirsi::Importer).to receive(:verbose) { false }
      Sirsi::Importer.import([sirsi_single_file, sirsi_full_file])
    end

    scenario 'viewing a library record held at Hull Local Studies Library' do
      visit catalog_path(id: '1667917') 
      expect(page).to have_link('Check if this item can be borrowed') 
    end
  end

  context 'ead-record' do
    before do
      Blacklight.solr.delete_by_query('*:*', params: { commit: true })
      allow(Ead::Parser).to receive(:verbose) { false }
      allow(Ead::Importer).to receive(:verbose) { false }
      Ead::Importer.import([ead_file])
    end

    scenario 'viewing a ead record that has a closed access status' do
        visit catalog_path(id: 'U-DAR-x1-4-1')
        expect(page).to have_content('This item is not currently available for consultation – please see the Access Conditions statement for more details.') 
    end

    scenario 'viewing a ead record that has a open access status' do
        visit catalog_path(id: 'U-DAR-x1-1-51-n')
        expect(page).to have_content('This item is reference only and can only be consulted in person at the Hull History Centre.') 
    end

  end

end