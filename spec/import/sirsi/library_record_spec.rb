require 'spec_helper'
require_relative '../../../lib/import/sirsi/library_record'

describe Sirsi::LibraryRecord do
  let(:id) { '123' }
  let(:reference_number) { 'L(SLA).326.8' }
  let(:title) { ['my title', 'title 2'] }
  let(:format) { "AFHDBK" }
  let(:subject) { ['Slave-trade--Great Britain--Early works to 1800.', 'Antislavery movements--Great Britain.'] }
  let(:sub_600) { 'Bond, Alice--Biography' }
  let(:sub_630) { 'Asiento treaty, 1713. [from old catalog]' }
  let(:sub_651) { 'Africa, Central--Description and travel.' }
  let(:author_100) { 'Fawcett, Bill' }
  let(:author_110) { 'Great Britain. Parliament. House of Commons.' }
  let(:author_700) { ['Carro, Joannes de,', 'Poulson, George,'] }
  let(:author_710) { 'English Heritage.' }
  let(:lang) { 'Parallel Latin text and English translation.' }
  let(:pub) { "Vienne, Impr. d'A. Strauss, 1814." }
  let(:phy_desc) { "48 p. : ill. (some col.), coats of arms, facsims., col. maps, ports. (chiefly col.) ; 24 cm." }
  let(:dates) { '1814' }
  let(:notes) { 'Includes index.' }
  let(:isbn) { '123' }

  let(:attrs) {{ id: id, reference_number: reference_number,
                 title: title, format: format,
                 subject: subject, subject_600: sub_600,
                 subject_630: sub_630, subject_651: sub_651,
                 author_100: author_100, author_110: author_110,
                 author_700: author_700, author_710: author_710,
                 language: lang, publisher: pub, dates: dates,
                 physical_desc: phy_desc, notes: notes,
                 isbn: isbn }}

  describe '.to_solr' do
    it 'converts attributes to a hash of solr fields' do
      solr_fields = Sirsi::LibraryRecord.to_solr(attrs)
      expect(solr_fields['type_ssi']).to eq 'library_record'
      expect(solr_fields['id']).to eq id
      expect(solr_fields['reference_no_ssi']).to eq reference_number
      expect(solr_fields['reference_no_ssort']).to eq reference_number
      expect(solr_fields['format_ssi']).to eq 'Book'
      expect(solr_fields['title_tesim']).to eq title
      expect(solr_fields['title_ssi']).to eq title.first
      expect(solr_fields['display_title_ss']).to eq "#{title.first}"
      expect(solr_fields['repository_ssi']).to eq 'Hull Local Studies Library'

      expect(solr_fields['subject_ssim']).to eq subject
      expect(solr_fields['subject_tesim']).to eq subject
      expect(solr_fields['personal_subject_ssim']).to eq sub_600
      expect(solr_fields['personal_subject_tesim']).to eq sub_600
      expect(solr_fields['corporate_subject_ssim']).to eq sub_630
      expect(solr_fields['corporate_subject_tesim']).to eq sub_630
      expect(solr_fields['geographical_subject_ssim']).to eq sub_651
      expect(solr_fields['geographical_subject_tesim']).to eq sub_651

      expect(solr_fields['author_tesim']).to eq [author_100, author_700, author_110, author_710].flatten
      expect(solr_fields['author_ssim']).to eq [author_100, author_700, author_110, author_710].flatten
      expect(solr_fields['language_ssim']).to eq lang
      expect(solr_fields['publisher_ssim']).to eq pub
      expect(solr_fields['dates_ssim']).to eq dates
      expect(solr_fields['dates_isim']).to eq dates.to_i
      expect(solr_fields['date_ssi']).to eq dates.to_i
      expect(solr_fields['physical_description_ssm']).to eq phy_desc
      expect(solr_fields['notes_ssm']).to eq notes
      expect(solr_fields['isbn_ssm']).to eq isbn
    end
  end

  describe '.authors' do
    it 'groups the authors in the correct order' do
      # Authors should appear in this order:
      # MARC fields: 100, 700, 110, 710
      expect(Sirsi::LibraryRecord.authors(attrs)).to eq [author_100, author_700, author_110, author_710].flatten
    end
  end

  describe 'format' do
    it 'standardizes the format' do
      solr_doc = Sirsi::LibraryRecord.to_solr(format: nil)
      expect(solr_doc['format_ssi']).to be_nil
      solr_doc = Sirsi::LibraryRecord.to_solr(format: 'CFHBK')
      expect(solr_doc['format_ssi']).to eq 'Book'
      solr_doc = Sirsi::LibraryRecord.to_solr(format: 'Something unexpected')
      expect(solr_doc['format_ssi']).to eq 'Something unexpected'
    end
  end

  describe 'standardize unknown dates' do
    it 'sets the date to "unknown"' do
      Sirsi::LibraryRecord.unknown_dates.each do |date|
        solr_fields = Sirsi::LibraryRecord.to_solr(dates: date)
        expect(solr_fields['dates_ssim']).to eq 'unknown'
        expect(solr_fields['dates_isim']).to eq nil
      end
    end

    it 'works for arrays too' do
      solr_fields = Sirsi::LibraryRecord.to_solr(dates: ['0', '1986'])
      expect(solr_fields['dates_ssim']).to eq ['unknown', '1986']
      expect(solr_fields['dates_isim']).to eq 1986
    end

    it 'ignore case differences' do
      solr_fields = Sirsi::LibraryRecord.to_solr(dates: ['N.D.', 'No Date'])
      expect(solr_fields['dates_ssim']).to eq ['unknown', 'unknown']
      expect(solr_fields['dates_isim']).to eq nil
    end
  end

end

