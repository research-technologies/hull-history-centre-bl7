# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightGoogleAnalytics::ControllerExtraHead

  
   before_action :show_tab, only: :show

  include BlacklightRangeLimit::ControllerOverride
  include BlacklightAdvancedSearch::Controller
  include BlacklightGoogleAnalytics::ControllerExtraHead

  include Blacklight::Catalog
  
  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt => 'search',
      :rows => 10 
    }
    
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}' 
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'display_title_ss'
    #config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    config.show.title_field = 'display_title_ss'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar
    config.add_facet_field 'format_ssi', label: 'Format', collapse: false, limit: 15
    config.add_facet_field 'dates_isim', label: 'Date', :range => true
    config.add_facet_field 'repository_ssi', label: 'Repository', limit: 5
    config.add_facet_field 'subject_ssim', label: 'Subject', limit: 15
    config.add_facet_field 'author_ssim', label: 'Author', limit: 15
    config.add_facet_field 'collection_id_ssi', label: 'Collection', show: false, helper_method: :title_by_id
    config.add_facet_field 'sub_collection_id_ssi', label: 'Subcollection', show: false, helper_method: :title_by_id
    config.add_facet_field 'series_id_ssi', label: 'Series', show: false, helper_method: :title_by_id
    config.add_facet_field 'sub_series_id_ssi', label: 'Subseries', show: false, helper_method: :title_by_id
    config.add_facet_field 'online_ssi', label: 'Availability', collapse: true

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'author_tesim', label: 'Author'
    config.add_index_field 'dates_ssim', label: 'Date'
    config.add_index_field 'extent_ssm', label: 'Extent'
    config.add_index_field 'reference_no_ssi', label: 'Reference No'

    # solr fields to be displayed in the show (single result) view
    # The ordering of the field names is the order of the display
    # config.add_show_field 'reference_no_ssi', label: 'Reference No'
    # NB: These are set directly in the views for each type of record


    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    config.add_search_field 'all_fields', :label => 'All Fields'
    
    config.add_search_field('title') do |field|
      field.solr_local_parameters = {
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end

    config.add_search_field('author') do |field|
      field.solr_local_parameters = {
        :qf => '$author_qf',
        :pf => '$author_pf'
      }
    end

    config.add_search_field('subject') do |field|
      field.solr_local_parameters = {
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

   config.add_search_field('reference_no') do |field|
      field.solr_local_parameters = {
        :qf => '$reference_no_qf',
        :pf => '$reference_no_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_ssi asc', :label => 'relevance'
    config.add_sort_field 'title_ssi asc, score desc', :label => 'title'
    config.add_sort_field 'date_ssi desc, title_ssi asc', :label => 'year'
    config.add_sort_field 'reference_no_ssort asc, score desc', :label => 'reference no.'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5

      config.advanced_search = {
        :query_parser => 'edismax',
        :url_key => 'advanced',
        :form_solr_parameters => {
          'facet.field' => ['format_ssi', 'repository_ssi', 'subject_ssim', 'author_ssim'],
        }
      }

  end
  
  protected

  def show_tab
    @show_tab = params['tab']
  end

  # Override rails path for the views so that we can match up
  # app/views/catalog (from blacklight) with 'catalog' controller.
  def _prefixes
    @_prefixes ||= super + ['catalog']
  end
end
