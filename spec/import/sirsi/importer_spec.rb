require 'rails_helper'
require_relative '../../../lib/import/sirsi'

describe Sirsi::Importer do
  let(:fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_sirsi_files')) }
  let(:sirsi_file) { File.join(fixtures_path, 'full_record_sample.xml') }

  before do
    allow(Sirsi::Importer).to receive(:verbose) { false }
    allow(Sirsi::Parser).to receive(:verbose) { false }
  end

  describe '.import' do
    it 'imports the records into solr documents' do
      Blacklight.solr.delete_by_query('*:*', params: {commit: true})
      Sirsi::Importer.import([sirsi_file])
      count = Blacklight.solr.select(params: {'q' => 'type_ssi:"library_record"'})['response']['numFound']
      expect(count).to eq 3

      doc = Blacklight.solr.select(params: {'q' => 'title_tesim:"Country ballads"'})['response']['docs'].first
      expect(doc['id']).to eq '1667617'
    end
  end

  describe '.import with errors' do
    let(:first_file) { sirsi_file }
    let(:second_file) { File.join(fixtures_path, 'single_sirsi_record.xml') }

    context 'when one file fails during import' do
      it 'continues importing the other files in the list' do
        expect(Sirsi::Parser).to receive(:parse).ordered.with(first_file).and_raise(StandardError.new('problem with file'))
        expect(Sirsi::Parser).to receive(:parse).ordered.with(second_file) { {} }
        Sirsi::Importer.import([first_file, second_file])
      end

      it 'returns the error messages' do
        expect(Sirsi::Parser).to receive(:parse).ordered.with(first_file).and_raise(StandardError.new('problem with file'))
        expect(Sirsi::Parser).to receive(:parse).ordered.with(second_file) { {} }
        errors = Sirsi::Importer.import([first_file, second_file])
        expect(errors).to eq ["#{first_file}: problem with file"]
      end
    end
  end
end
