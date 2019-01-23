require 'rails_helper'

describe CatalogueController do
  describe "GET show" do
    before { get :show, id: 1, tab: 'my_tab' }
    
    it 'keeps track of the tab the user wants to view' do
      expect(assigns[:show_tab]).to eq 'my_tab'
    end
  end
end
