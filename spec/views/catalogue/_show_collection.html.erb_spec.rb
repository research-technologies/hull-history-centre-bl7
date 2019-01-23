require 'rails_helper'

describe 'catalog/_show_collection.html.erb' do
  let(:doc) { SolrDocument.new(id: '1') }
  let(:summary_content) { 'Stub content for summary tab' }
  let(:desc_content) { 'Stub content for description tab' }
  let(:arr_content) { 'Stub content for arrangement tab' }
  let(:rel_content) { 'Stub content for related material tab' }

  before do
    stub_template 'catalog/_show_collection_summary.html.erb' => summary_content
    stub_template 'catalog/_show_collection_description.html.erb' => desc_content
    stub_template 'catalog/_show_collection_arrangement.html.erb' => arr_content
    stub_template 'catalog/_show_collection_related.html.erb' => rel_content

    assign :show_tab, tab
    render partial: 'catalog/show_collection.html.erb',
           locals: { document: doc }
  end

  describe 'tabs' do
    context 'with no tab selected' do
      let(:tab) { nil }

      it 'displays the summary tab and highlights summary link' do
        expect(rendered).to     have_content(summary_content)
        expect(rendered).to_not have_content(desc_content)
        expect(rendered).to_not have_content(arr_content)
        expect(rendered).to_not have_content(rel_content)

        expect(rendered).to have_xpath('//a[@class="current-tab tab-menu-item col-md-12"][@href="/catalog/1?tab=summary"]', count: 1)
      end
    end

    context 'with description tab selected' do
      let(:tab) { 'description' }

      it 'displays the desc tab and highlights desc link' do
        expect(rendered).to_not have_content(summary_content)
        expect(rendered).to     have_content(desc_content)
        expect(rendered).to_not have_content(arr_content)
        expect(rendered).to_not have_content(rel_content)

        expect(rendered).to have_xpath('//a[@class="current-tab tab-menu-item col-md-12"][@href="/catalog/1?tab=description"]', count: 1)
      end
    end
  end
end
