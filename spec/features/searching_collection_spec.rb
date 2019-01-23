require 'rails_helper'
require 'import/ead'

feature 'Searching within a collection:' do
  let(:fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_ead_files')) }
  let(:ddh_file) { File.join(fixtures_path, 'U_DDH.xml') }
  let(:dar_file) { File.join(fixtures_path, 'U_DAR_single_item.xml') }
  let(:search_term) { 'socialist' }

  before do
    Blacklight.solr.delete_by_query("*:*", params: { commit: true })
    allow(Ead::Parser).to receive(:verbose) { false }
    allow(Ead::Importer).to receive(:verbose) { false }
    Ead::Importer.import([ddh_file, dar_file])
  end

  scenario 'find results only within this collection' do
    # Both collections contain items that have the word
    # 'socialist' in the title.  If we query without
    # scoping to a certain collection, there is more
    # than 1 result.
    query = "title_tesim:#{search_term}"
    result = Blacklight.solr.select(params: { q: query })
    total_results = result['response']['numFound']
    expect(total_results > 1).to eq true

    # Search within a collection:
    visit catalog_path('U-DAR', tab: 'search')
    fill_in :q_collection, with: search_term
    click_button :search_collection

    # Should only get 1 result
    expect(page).to have_selector('#documents .document', count: 1)

    # The collection should be listed in the applied filters
    expect(page).to have_selector('#appliedParams .filterName', text: 'Collection')
    expect(page).to have_selector('#appliedParams .filterValue', text: 'Papers of Robin Page Arnot')
  end
end
