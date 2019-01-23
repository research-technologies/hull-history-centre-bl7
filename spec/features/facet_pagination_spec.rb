require 'rails_helper'
require 'import/ead'

feature 'Facet pagination:' do
  let(:fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_ead_files')) }
  let(:dar_file) { File.join(fixtures_path, 'U_DAR_pruned.xml') }

  before do
    Blacklight.solr.delete_by_query("*:*", params: { commit: true })
    allow(Ead::Parser).to receive(:verbose) { false }
    allow(Ead::Importer).to receive(:verbose) { false }
    Ead::Importer.import(dar_file)
  end

  scenario 'Selecting a facet limit' do
    visit catalog_index_path

    fill_in 'range_dates_isim_begin', with: '1970'
    fill_in 'range_dates_isim_end', with: '1972'

    within('#facet-dates_isim') do
       click_button 'Limit'
    end
   
    # Should have 10 search results
    expect(page).to have_selector('#documents .document', count: 10)

    # The search constraints should include the date 1970 to 1972 
    expect(page).to have_selector('.filterName', count: 1, text: 'Date')
    expect(page).to have_selector('.filterValue', count: 1, text: '1970 to 1972')
  end

end

