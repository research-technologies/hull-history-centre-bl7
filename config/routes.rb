ALLOW_DOTS ||= /[a-zA-Z0-9_.:-]+/

Rails.application.routes.draw do

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'
  
  # Switch over to this when home page has been created
  root to: 'pages#home'
  # root :to => "catalogue#index"

  # ERROR undefined method `blacklight_for'
  # @todo check if this ALLOW DOTS contraint is needed
  # blacklight_for :catalogue, constraints: { id: ALLOW_DOTS }

  resources :catalog, controller: 'catalog', path: '/catalogue'
  
  # Add LB healthcheck page
  get 'healthcheck/rails-status' => 'pages#rails_status'

  %w[home about contact cookies help].each do |page|
    get page, controller: 'pages', action: page
  end
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalogue, only: [:index], as: 'catalog', path: '/catalogue', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalogue', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
