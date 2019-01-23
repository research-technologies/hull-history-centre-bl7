require 'rails_helper'

describe 'catalog/_show_collection_description.html.erb' do
  before do
    render partial: 'catalog/show_collection_description.html.erb',
           locals: { document: SolrDocument.new(fields) }
  end

  context 'happy path' do
    let(:fields) {{ 'description_tesim' => ['desc1', 'desc2'],
                    'biog_hist_ssm' => ['bio1', 'bio2'] }}

    it 'displays the data' do
      expect(rendered).to have_content('desc1 desc2')
      expect(rendered).to have_content('bio1 bio2')
    end
  end

  context 'with String data' do
    let(:fields) {{ 'description_tesim' => 'desc1',
                    'biog_hist_ssm' => 'bio1' }}

    it 'displays the data' do
      expect(rendered).to have_content('desc1')
      expect(rendered).to have_content('bio1')
    end
  end

  context 'with missing data' do
    let(:fields) {{ 'description_tesim' => nil,
                    'biog_hist_ssm' => nil }}

    it 'doesnt blow up' do
      expect(rendered).to have_content('Description')
    end
  end
end
