ALLOW_DOTS ||= /[a-zA-Z0-9_.:-]+/

Rails.application.routes.draw do

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'
  
  # from hhc start
  # Switch over to this when home page has been created
  root to: 'pages#home'
  # root :to => "catalogue#index"

  # blacklight_for :catalogue, constraints: { id: ALLOW_DOTS }

  resources :catalog, controller: 'catalog'
  
  # Add LB healthcheck page
  get 'healthcheck/rails-status' => 'pages#rails_status'

  %w[home about contact cookies help].each do |page|
    get page, controller: 'pages', action: page
  end

  # root to: "catalog#index"
  
  # from hhc end
  
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable

  end
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
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
