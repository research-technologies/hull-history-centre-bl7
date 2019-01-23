require 'spec_helper'
require_relative '../../../lib/import/sirsi'

describe Sirsi::Parser do
  let(:fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_sirsi_files')) }
  let(:single_item) { File.join(fixtures_path, 'single_sirsi_record.xml') }
  let(:sirsi_records) { File.join(fixtures_path, 'full_record_sample.xml') }
  let(:bad_file) { File.join(fixtures_path, 'bad_file.xml') }

  before do
    allow(Sirsi::Parser).to receive(:verbose) { false }
  end

  describe '.attrs_for_record' do
    let(:attrs) {
      xml = Nokogiri::XML(File.read(single_item)).xpath("//#{Sirsi::LibraryRecord.root_xpath}")
      Sirsi::Parser.attrs_for_record(xml, Sirsi::LibraryRecord)
    }

    it 'finds the attributes for that record' do
      expect(attrs[:id]).to eq '1667917'
      expect(attrs[:reference_number]).to eq 'L(SLA).326.8'
      expect(attrs[:title]).to match(/Abrâegâe des preuves/)
      expect(attrs[:format]).to eq 'ANFHBK'

      expect(attrs[:subject]).to eq ['Slave-trade--Great Britain--Early works to 1800.', 'Antislavery movements--Great Britain.']
      expect(attrs[:subject_600]).to eq 'Bond, Alice--Biography'
      expect(attrs[:subject_630]).to eq 'Asiento treaty, 1713. [from old catalog]'
      expect(attrs[:subject_651]).to eq 'Africa, Central--Description and travel.'

      expect(attrs[:author_100]).to eq 'Fawcett, Bill'
      expect(attrs[:author_700]).to eq ['Carro, Joannes de,', 'Poulson, George,']
      expect(attrs[:author_110]).to eq 'Great Britain. Parliament. House of Commons.'
      expect(attrs[:author_710]).to eq 'English Heritage.'
      expect(attrs[:language]).to eq 'Parallel Latin text and English translation.'
      expect(attrs[:publisher]).to eq "Vienne, Impr. d'A. Strauss, 1814."
      expect(attrs[:physical_desc]).to eq '186 p. ; 22 cm.'
      expect(attrs[:dates]).to eq '1814'
      expect(attrs[:notes]).to eq 'Spine title: History of Barton.'
      expect(attrs[:isbn]).to eq '0852062907'
    end
  end

  describe '.parse' do
    it 'returns a hash with attributes for all the library records' do
      records = Sirsi::Parser.parse(sirsi_records)
      expect(records[:library_records].count).to eq 3
    end

    it 'raises an error if it cant parse the file' do
      expect{
        Sirsi::Parser.parse(bad_file)
      }.to raise_error "No records found.  Please check that you have valid XML."
    end
  end
end

