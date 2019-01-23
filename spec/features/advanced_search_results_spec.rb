require 'rails_helper'
require 'import/ead'

describe "Advanced Search Results" do

  let(:fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_ead_files')) }
  let(:test_ead) { File.join(fixtures_path, 'C_DBCO_pruned.xml') }  

  before do
    Blacklight.solr.delete_by_query("*:*", params: { commit: true })
    allow(Ead::Parser).to receive(:verbose) { false }
    allow(Ead::Importer).to receive(:verbose) { false }
    Ead::Importer.import(test_ead)
  end

  describe "reference number search" do
     it "should return the expected result with a quoted search" do
       search_for '"C DBCO"'
       expect(number_of_results_from_page(page)).to eq 4
       expect(page).to have_content("Records of Comet Group PLC (1933-2012)")
     end

     it "should return the expected single result with a exact quoted search" do
       search_for '"C DBCO/1/1/1"'
       expect(number_of_results_from_page(page)).to eq 1
       expect(page).to have_content("Comet Radiovision Services Ltd Minute Book")
     end     
  end

  def search_for q
    visit advanced_search_path
    fill_in "reference_no", with: q
    click_button 'advanced-search-submit'
  end

  def number_of_results_from_page(page)
    tmp_value = Capybara.ignore_hidden_elements
    Capybara.ignore_hidden_elements = false
    val = page.find("meta[name=totalResults]")['content'].to_i rescue 0
    Capybara.ignore_hidden_elements = tmp_value
    val
  end
  
end