require 'rails_helper'

describe 'Catalogue routes' do

  describe 'GET show' do
    let(:id) { "L-WH-1-1.1-01a" }

    it 'routes to show' do
      expect(get: "catalog/#{id}").to route_to(
        controller: 'catalog',
        action: 'show',
        id: id
      )
    end
  end

  describe 'POST track' do
    let(:id) { "L-WH-11-11.1-13-01a" }

    it 'routes to track' do
      expect(post: "catalog/#{id}/track").to route_to(
        controller: 'catalog',
        action: 'track',
        id: id
      )
    end
  end

end
