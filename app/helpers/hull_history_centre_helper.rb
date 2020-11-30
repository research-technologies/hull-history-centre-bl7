require "kaminari"
#Class User < ActiveRecord::Base
#   paginates_per 50
#end


module HullHistoryCentreHelper

  ##############################################
  # Blacklight Overrides 
  # FacetHelpers 
  ##############################################
  # Standard display of a SELECTED facet value (e.g. without a link and with a remove button)
  # @params (see #render_facet_value)
  def render_selected_facet_value(facet_solr_field, item)
    content_tag(:span, :class => "facet-label") do
      content_tag(:span, facet_display_value(facet_solr_field, item), :class => "selected") + render_facet_count(item.hits, :classes => ["selected"])
    end
  end
  
  ##############################################
  # End of Blacklight overides
  ##############################################
  
  def title_by_id(value)
    query = 'id:"' + value + '"'
    result = Blacklight.solr.select(params: { q: query })
    doc = result['response']['docs'].first
    name = doc.blank? ? value : Array(doc['title_tesim']).first
  rescue
    value
  end

  def isbn(document)
    isbn = document['isbn_ssm'] #document.get("isbn_ssm", sep: nil) 
    isbn = isbn.nil? ? nil : isbn.first
  end

  def render_selected_facet_value(facet_solr_field, item)
    content_tag(:span, :class => "facet-label") do
    content_tag(:span, facet_display_value(facet_solr_field, item), :class => "selected") + render_facet_count(item.hits, :classes => ["selected"])
    # remove link
    #link_to(content_tag(:span, '', :class => "glyphicon glyphicon-remove") + content_tag(:span, '[remove]', :class => 'sr-only'), search_action_path(remove_facet_params(facet_solr_field, item, params)), :class=>"remove")
    #end + render_facet_count(item.hits, :classes => ["selected"])
    end
  end

  # Returns the Resource type/Format from the Solr document
  def resource_type_from_document(document)
    resource_type = ""

    #type_ssi
    #resource_type = document["format_ssi"] unless document["format_ssi"].nil?
    resource_type = document["format_ssi"] || document["type_ssi"]
    resource_type = resource_type.is_a?(Array) ? resource_type.first : resource_type
  end

  def display_resource_thumbnail(document, opts={})
    options = { id: '', class: 'img-responsive thumbnail-image' }.merge(opts) #defaults
    content_tag(:img, nil, class: options[:class], id: options[:id], src: thumbnail_src_from_document(document) )
  end

  def thumbnail_src_from_document(document)
    resource_type = resource_type_from_document(document)

    thumbnail_src = case resource_type
    when "Book"
      asset_path "icon-flat-book.png"
    when "CD/DVD"
      asset_path "icon-flat-dvd.png"
    when "Map"
      asset_path "icon-flat-map.png"
    when "Microfilm"
      asset_path "icon-flat-microfilm.png"
    when "Archive Collection"
      asset_path "icon-flat-archive.png"
    when "Archive Item", "piece", "item", "series", "subcollection", "subseries"
      asset_path "icon-flat-archive-item.png"
    when "Video"
      asset_path "icon-flat-video.png"
    # no icons created yet
    #when "Newspaper"
      #asset_path "icon-flat-file"
    #when "Pamphlet"
      #asset_path "icon-flat-file"
    #when "Cassette"
      #asset_path "icon-flat-file"

    else
       asset_path "icon-flat-generic.png"
    end

  end

  # Returns a collection pdf url based upon a pre-defined format for pdf naming.  
  def collection_pdf_url(id, label="Link")
    unless id.nil? 
      filename = "#{id.downcase}.pdf"
      return link_to label, "/files/#{filename}"
    end
  end
  
  def file_set_urls(document_id)
    result = Blacklight.default_index.connection.get('select', params: {
        q: '*:*', 
        fq: "{!join from=file_set_ids_ssim to=id}id:\"#{document_id}\"",
        fl: 'id,file_name_tesim,mime_type_ssi',
        rows: 1000,
      })['response']['docs']
      #TODO workout how to sort this list with solr query
      # adding param "sort: 'file_name_tesim'" breaks stuff
      # Use ruby to sort for now
      sorted = result.sort_by { |k| k["file_name_tesim"][0] }
  end

  def file_set_url(file_set_id)
    "https://#{ENV['HYRAX_SERVER_NAME']}/downloads/#{file_set_id}"
  end
  
  def manifest(dao_id)
    "https://#{ENV['HYRAX_SERVER_NAME']}/concern/digital_archival_objects/#{dao_id}/manifest"
  end
  
  def contains?(type,document_id)
     files=file_set_urls(document_id)
     m=mime_types
     Rails.logger.warn(m)
     files.each do |f|
       if m[type].include?(f['mime_type_ssi'])
         return true
       end
     end
     return false
  end

#  def image?(mime_type)
#    image_mime_types.include?(mime_type)
#  end

  def mime_types
    {image: ['image/png', 'image/jpeg', 'image/jpg', 'image/jp2', 'image/bmp', 'image/gif', 'image/tiff'],
     pdf: ['application/pdf', 'application/x-pdf'],
     audio: ['audio/mpeg', 'audio/mp4', 'audio/x-aiff', 'audio/ogg', 'audio/vorbis', 'audio/vnd.wav'],
     video: ['video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/x-ms-wmv']}
  end

end
