require 'rails_helper'
require 'import/ead'

describe "Search Results" do
  let(:fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_ead_files')) }
  let(:test_ead) { File.join(fixtures_path, 'iso_chars.xml') }

  before do
    Blacklight.solr.delete_by_query("*:*", params: { commit: true })
    allow(Ead::Parser).to receive(:verbose) { false }
    allow(Ead::Importer).to receive(:verbose) { false }
    Ead::Importer.import(test_ead)
  end

  it "should have for an empty query" do
    search_for ''
    expect(number_of_results_from_page(page)).to eq 3
    expect(page).to have_content('Birmingham Six Case Papers')
  end

  it "should have for an all fields query" do
    search_for 'parliamentary questions and debates'
    expect(number_of_results_from_page(page)).to eq 2
    expect(page).to have_content('Papers of Chris Mullin MP Relating to Miscarriages of Justice')
  end
end

def search_for q
  visit catalog_index_path
  fill_in "q", with: q
  click_button 'search'
end

def number_of_results_from_page(page)
  tmp_value = Capybara.ignore_hidden_elements
  Capybara.ignore_hidden_elements = false
  val = page.find("meta[name=totalResults]")['content'].to_i rescue 0
  Capybara.ignore_hidden_elements = tmp_value
  val
end
