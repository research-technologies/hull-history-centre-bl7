require 'rails_helper'
require "uri"

RSpec.describe ShowHelper, type: :helper do
  let(:title_example_one) { "The life and times of"}
  let(:title_example_two) { "This is a title that includes a slash and author concat / By Me"}
  let(:sample_document) { { 'id' => 'Test-1-1', 'type_ssi' => 'subseries' } }

  describe "#prism_search_link" do
    before(:each) do
      HullHistoryCentre::Application.config.prism_server_name = "prism-test.server.org"
    end

    it "returns the expected search url" do
      expect(helper.prism_search_link(title_example_one)).to include("http://prism-test.server.org/uhtbin/cgisirsi.exe/x/HULLCENTRL/x/57/5?user_id=HULLWEB&amp;searchdata1=The%20life%20and%20times%20of")
    end 

    it "returns the search url without a concatenated author" do
        expect(helper.prism_search_link(title_example_two)).to include("http://prism-test.server.org/uhtbin/cgisirsi.exe/x/HULLCENTRL/x/57/5?user_id=HULLWEB&amp;searchdata1=This%20is%20a%20title%20that%20includes%20a%20slash%20and%20author%20concat%20")
    end

  end

  describe "#sub_items_link" do
     it "returns the expected sub items query link" do
        target_query_params = '?f%5Bsub_series_id_ssi%5D%5B%5D=Test-1-1'
        expect(helper.sub_items_link(sample_document)).to include(target_query_params)
     end   
  end

end