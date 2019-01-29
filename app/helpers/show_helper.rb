require "uri"

module ShowHelper

  def show_attribute(document, field, label)
    unless document[field].blank?
      label = content_tag(:dt, label + ':')
      value = Array(document[field]).join(' ').html_safe
      value = content_tag(:dd, value)
      content_tag(:span, label + value)
    end
  end

  def breadcrumbs(document)
    keys = [['collection_title_ss', 'collection_id_ssi'],
            ['sub_collection_title_ss', 'sub_collection_id_ssi'],
            ['series_title_ss', 'series_id_ssi'],
            ['sub_series_title_ss', 'sub_series_id_ssi'],
            ['item_title_ss', 'item_id_ssi']
    ]

    # If we have the ID for a solr document, the breadcrumb
    # should be a link to that document.  Else, just print the
    # breadcrumb's title as a String.
    crumbs = keys.map do |(title_key, id_key)|
      breadcrumb_title = document[title_key]
      if document[id_key].present?
        link_to breadcrumb_title, catalog_path(document[id_key])
      else
        breadcrumb_title
      end
    end

    current_crumb = document['title_tesim'].first
    crumbs = crumbs + [current_crumb]
    crumbs = crumbs.compact.join(' &gt; ').html_safe
  end

  def sub_items_link(document)
    keys = { "subseries" => "sub_series_id_ssi",
                     "series" => "series_id_ssi",
                       "subcollection" => "sub_collection_id_ssi" 
                }

    search_id_field =  keys[document['type_ssi']].to_s 

    unless search_id_field.empty?
      link_to(t("blacklight.show.child_items_link"), catalog_index_path( "f[#{ search_id_field }][]" => document["id"]))
    end     
  end

  def author_label(solr_doc)
    author_count = Array(solr_doc['author_tesim']).count
    author_count > 1 ? 'Authors: ' : 'Author: '
  end

  def prism_search_link(library_record_title)
      unless library_record_title.nil? 
        term = library_record_title.split("/").first # Split any concatenated authors from the title 
        link_to(t("blacklight.show.availability_link"),  prism_search_url(term), target: "_blank")
      end
  end

  def ead_item_access_closed?(document)
    document["access_status_ssi"] == "closed" ? true : false
  end 

  def prism_search_url(search_term)
    "http://#{HullHistoryCentre::Application.config.prism_server_name}/uhtbin/cgisirsi.exe/x/HULLCENTRL/x/57/5?user_id=HULLWEB&searchdata1=#{URI.encode(search_term)}"
  end

end
