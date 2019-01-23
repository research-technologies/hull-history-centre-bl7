require 'rails_helper'

describe 'Pages routes' do

  describe 'Home show' do
    it 'routes to show' do
      expect(get: "home").to route_to(
        controller: 'pages',
        action: 'home',
      )
    end
  end

  describe 'About show' do
    it 'routes to show' do
      expect(get: "about").to route_to(
        controller: 'pages',
        action: 'about',
      )
    end
  end

    describe 'Contact show' do
    it 'routes to show' do
      expect(get: "contact").to route_to(
        controller: 'pages',
        action: 'contact',
      )
    end
  end

    describe 'Help show' do
    it 'routes to show' do
      expect(get: "help").to route_to(
        controller: 'pages',
        action: 'help',
      )
    end
  end

    describe 'Cookies show' do
    it 'routes to show' do
      expect(get: "cookies").to route_to(
        controller: 'pages',
        action: 'cookies',
      )
    end
  end

end
