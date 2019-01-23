require 'rails_helper'

describe 'catalog/_breadcrumbs.html.erb' do

  before do
    render partial: 'catalog/breadcrumbs.html.erb',
           locals: { document: SolrDocument.new(fields) }
  end

  describe 'Breadcrumbs for an archival Item:' do
    context 'happy path' do
      let(:fields) {{ 'collection_title_ss' => 'c title',
                      'collection_id_ssi' => '3',
                      'sub_collection_title_ss' => 'sc title',
                      'sub_collection_id_ssi' => '3a',
                      'series_title_ss' => 's title',
                      'series_id_ssi' => '2',
                      'sub_series_title_ss' => 'sa title',
                      'sub_series_id_ssi' => '2a',
                      'title_tesim' => ['t1', 't2'],
                      'id' => '1' }}

      it 'displays breadcrumb links' do
        expect(rendered).to have_link(fields['collection_title_ss'], href: catalog_path(fields['collection_id_ssi']))
        expect(rendered).to have_link(fields['sub_collection_title_ss'], href: catalog_path(fields['sub_collection_id_ssi']))
        expect(rendered).to have_link(fields['series_title_ss'], href: catalog_path(fields['series_id_ssi']))
        expect(rendered).to have_link(fields['sub_series_title_ss'], href: catalog_path(fields['sub_series_id_ssi']))
        expect(rendered).to have_content(fields['title_tesim'].first)
        expect(rendered).to_not have_link(fields['title_tesim'].first, href: catalog_path(fields['id']))
      end
    end

    # We might have sparse data for sub-collection, series,
    # and sub-series, so there might only be a title and no
    # other data.
    context 'missing IDs for some breadcrumbs' do
      let(:fields) {{ 'collection_title_ss' => 'c title',
                      'collection_id_ssi' => nil,
                      'series_title_ss' => 's title',
                      'series_id_ss' => nil,
                      'title_tesim' => ['t1', 't2'],
                      'id' => '1' }}

      it 'displays text instead of links' do
        expect(rendered).to_not have_link(fields['collection_title_ss'])
        expect(rendered).to_not have_link(fields['series_title_ss'])
        expect(rendered).to_not have_link(fields['title_tesim'])

        expect(rendered).to have_content(fields['collection_title_ss'].first)
        expect(rendered).to have_content(fields['series_title_ss'].first)
        expect(rendered).to have_content(fields['title_tesim'].first)
      end
    end

  end
end
