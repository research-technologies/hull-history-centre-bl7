require 'rails_helper'

describe 'catalog/_show_collection_arrangement.html.erb' do
  before do
    render partial: 'catalog/show_collection_arrangement.html.erb',
           locals: { document: SolrDocument.new(fields) }
  end

  context 'happy path' do
    let(:fields) {{ 'arrangement_ssm' => ['arr1', 'arr2'] }}

    it 'displays the arrangement' do
      expect(rendered).to have_content('arr1arr2')
    end
  end

  context 'with String data' do
    let(:fields) {{ 'arrangement_ssm' => 'arr1' }}

    it 'displays the arrangement' do
      expect(rendered).to have_content('arr1')
    end
  end

  context 'no data' do
    let(:fields) {{ 'arrangement_ssm' => nil }}

    it 'doesnt blow up' do
      expect(rendered).to have_content('Arrangement')
    end
  end
end
