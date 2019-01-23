require 'spec_helper'
require_relative '../../../lib/import/ead'

describe Ead::Parser do
  let(:fixtures_path) { File.expand_path(File.join('spec', 'fixtures', 'sample_ead_files')) }
  let(:ddh_file) { File.join(fixtures_path, 'U_DDH.xml') }
  let(:bad_file) { File.join(fixtures_path, 'bad_file.xml') }
  let(:single_item) { File.join(fixtures_path, 'U_DAR_single_item.xml') }
  let(:item_with_sub_series) { File.join(fixtures_path, 'C_DBCO_pruned.xml') }

  before do
    allow(Ead::Parser).to receive(:verbose) { false }
  end

  describe 'encoding' do
    let(:iso_chars_file) { File.join(fixtures_path, 'iso_chars.xml') }
    it 'converts data to UTF-8' do
      data = File.read(iso_chars_file)
      doc = Nokogiri::XML(data)
      expect(doc.encoding).to eq 'ISO-8859-1'

      xml = doc.xpath('*')
      items = Ead::Parser.parse_records(xml, Ead::Item)
      expect(items.count).to eq 1

      desc = items.first[:description][6]
      expect(desc.encoding).to eq Encoding::UTF_8

      #expected_result = '<p>Parliamentary Questions for the D&#xE1;il &#xC9;ireann</p>'
      expected_result = '<p>Parliamentary Questions for the Dáil Éireann</p>'
      expect(desc).to eq expected_result
    end
  end

  describe 'attrs_for_record' do
    context 'for a single Piece' do
      it 'finds the attributes for that piece' do
        xml = Nokogiri::XML(File.read(single_item)).xpath("//#{Ead::Piece.root_xpath}")
        attrs = Ead::Parser.attrs_for_record(xml, Ead::Piece)
        expect(attrs[:title]).to match /Letter Robin Page Arnot to George Bernard Shaw/
        expect(attrs[:dates]).to eq '11 Nov 1947'
        expect(attrs[:dates_normal]).to eq '1947-1947'
        expect(attrs[:extent]).to eq '2 items'
        expect(attrs[:repository]).to eq 'Hull University Archives'
        expect(attrs[:id]).to eq 'U DAR/x1/1/51/f'
        expect(attrs[:item_id]).to eq 'U DAR/x1/1/51'
        expect(attrs[:item_title]).to eq 'File. Shaw, George Bernard, added socialist to the title'
        expect(attrs[:description]).to eq "Returned with holograph note from George Bernard Shaw: - 'impossible: it would damage Dutt...', no date"
        expect(attrs[:language]).to eq 'English (UK)'
      end
    end

    context 'for a single Item' do
      it 'finds the attributes for that item' do
        xml = Nokogiri::XML(File.read(single_item)).xpath("//#{Ead::Item.root_xpath}")
        attrs = Ead::Parser.attrs_for_record(xml, Ead::Item)
        expect(attrs[:id]).to eq 'U DAR/x1/1/51'
        expect(attrs[:title]).to eq 'File. Shaw, George Bernard, added socialist to the title'
        expect(attrs[:repository]).to eq 'Hull University Archives'
        expect(attrs[:extent]).to eq '1 file'
        expect(attrs[:access]).to eq ['<p>Access will be granted to any accredited reader</p>', '<p> Paragraph 2 </p>']
        expect(attrs[:description]).to eq ['<p>desc 1</p>', '<p>desc 2</p>']
        expect(attrs[:dates]).to eq '1941 - 1972'
        expect(attrs[:dates_normal]).to eq '1941-1972'
        expect(attrs[:access_status]).to eq "Closed"
        expect(attrs[:collection_id]).to eq 'U DAR'
        expect(attrs[:collection_title]).to eq 'Papers of Robin Page Arnot'
        expect(attrs[:sub_collection_title]).to eq 'First Deposit'
        expect(attrs[:series_title]).to eq 'General Files'
        expect(attrs[:language]).to eq 'English (UK)'
      end

      it 'finds sub_series attributes' do
        xml = Nokogiri::XML(File.read(item_with_sub_series)).xpath("//#{Ead::Item.root_xpath}")
        attrs = Ead::Parser.attrs_for_record(xml, Ead::Item)
        expect(attrs[:sub_series_title]).to eq 'Comet Radiovision Services Ltd Minute Books'
        expect(attrs[:sub_series_id]).to eq 'C DBCO/1/1'
      end
    end


    context 'for a subseries' do
      it 'finds the attributes for that subseries' do
        xml = Nokogiri::XML(File.read(item_with_sub_series)).xpath("//#{Ead::SubSeries.root_xpath}")
        attrs = Ead::Parser.attrs_for_record(xml, Ead::SubSeries)
        expect(attrs[:id]).to eq 'C DBCO/1/1'
        expect(attrs[:title]).to eq 'Comet Radiovision Services Ltd Minute Books'
        expect(attrs[:repository]).to eq 'Hull City Archives'
        expect(attrs[:extent]).to eq '8 items'
        expect(attrs[:access]).to eq 'Access will be granted to any accredited reader'
        expect(attrs[:description]).to eq 'Subseries contains minute books recording ordinary Board meetings of Comet Radiovision Services Limited. Please note that minutes of AGMs can be found under the reference C DBCO/1/3.'
        expect(attrs[:dates]).to eq '1972-1988'
        expect(attrs[:dates_normal]).to eq '1972-1988'
        expect(attrs[:collection_id]).to eq 'C DBCO'
        expect(attrs[:collection_title]).to eq 'Records of Comet Group PLC (1933-2012)'
        expect(attrs[:series_title]).to eq 'Comet Group PLC Minute Books'
        expect(attrs[:series_id]).to eq 'C DBCO/1'        
        # Awaiting clarification from Simon  W
        #expect(attrs[:series_title]).to eq 'Comet Group PLC Minute Books'
      end
    end

    context 'for a single subcollection' do
      it 'finds the attributes for that subcollection' do
        xml = Nokogiri::XML(File.read(single_item)).xpath("//#{Ead::SubCollection.root_xpath}")
        attrs = Ead::Parser.attrs_for_record(xml, Ead::SubCollection)
        expect(attrs[:id]).to eq 'U DAR/x1'
        expect(attrs[:title]).to eq 'First Deposit'
        expect(attrs[:repository]).to eq 'Hull University Archives'
        expect(attrs[:description].first).to match(/General files, 1896 - 1976/)
        expect(attrs[:dates_normal]).to eq '1896-1978'

        expect(attrs[:collection_id]).to eq 'U DAR'
        expect(attrs[:collection_title]).to eq  'Papers of Robin Page Arnot'
      end
    end

    context 'for a single Collection' do
      it 'finds the attributes for that collection' do
        xml = Nokogiri::XML(File.read(ddh_file))
        collection_node = xml.xpath("//#{Ead::Collection.root_xpath}").first
        attrs = Ead::Parser.attrs_for_record(collection_node, Ead::Collection)
        expect(attrs[:id]).to eq 'U DDH'
        expect(attrs[:title]).to eq 'Papers of Denzil Dean Harber'
        expect(attrs[:repository]).to eq 'Hull University Archives'
        expect(attrs[:dates]).to eq '1932-1946'
        expect(attrs[:dates_normal]).to eq '1932-1946'
        expect(attrs[:extent]).to eq '2 boxes'
        expect(attrs[:access]).to eq 'Access will be given to any accredited reader'
        expect(attrs[:custodial_history]).to eq ['<p>Copied with the permission of Julian Harber</p>', '<p>Another paragraph</p>']
        expect(attrs[:language]).to eq 'English'
        expect(attrs[:biog_hist].count).to eq 2
        expect(attrs[:biog_hist].first).to match(/<p>Denzil Harber was born at 25 Fairmile Avenue, Streatham, on 25 Jan 1909./)
        expect(attrs[:description].count).to eq 2
        expect(attrs[:description].first).to match(/statements and correspondence of the Revolutionary Socialist League/)
        expect(attrs[:arrangement].count).to eq 4
        expect(attrs[:arrangement].first).to eq '<p>U DDH/1	Various parties, 1932-1938</p>'
        expect(attrs[:related].count).to eq 4
        expect(attrs[:related].first).to eq '<p>Papers of Jock Haston (records of the Revolutionary Communist Party) [U DJH]</p>'
        expect(attrs[:pub_notes]).to eq "John Archer, Trotskyism in Britain 1931-37 (PhD Thesis, Central London Polytechnic, 1979)\nReginald Groves, The Balham Group: how British Trotskyism began (Pluto Press Ltd, 1974)"
        expect(attrs[:copyright]).to eq 'Julian Harber'
      end
    end
  end

  describe '.parse_records' do
    context 'for Item records' do
      it 'finds the attributes for all items' do
        xml = Nokogiri::XML(two_items).xpath('*')
        items = Ead::Parser.parse_records(xml, Ead::Item)
        expect(items.count).to eq 2
        expect(items.last[:id]).to eq 'U DDH/14'
        expect(items.last[:title]).to eq 'Photocopy. Revolutionary Communist Party'
      end
    end

    context 'for Collection records' do
      it 'finds the attributes for the collection(s)' do
        xml = Nokogiri::XML(File.read(ddh_file))
        collections = Ead::Parser.parse_records(xml, Ead::Collection)
        expect(collections.count).to eq 1
        expect(collections.first[:id]).to eq 'U DDH'
        expect(collections.first[:title]).to eq 'Papers of Denzil Dean Harber'
      end
    end
  end

  describe '.parse' do
    let(:dar_file) { File.join(fixtures_path, 'U_DAR_pruned.xml') }

    it 'returns a hash of object attributes' do
      objects = Ead::Parser.parse(dar_file)
      expect(objects[:collections].count).to eq 1
      expect(objects[:items].count).to eq 11
      expect(objects[:pieces].count).to eq 27
    end

    it 'raises an error if it cant parse the file' do
      expect{
        Ead::Parser.parse(bad_file)
      }.to raise_error "No records found.  Please check that you have valid XML."
    end
  end

end


def item_13
  <<-END13
    <c level="item">
      <did>
        <unittitle encodinganalog="3.1.2">Photocopy. Workers&apos; International League </unittitle>
        <unitdate datechar="creation" encodinganalog="3.1.3.2" label="Creation Dates" type="inclusive" normal="1938-1942">1938-1942</unitdate>
        <physdesc encodinganalog="3.4.4" label="Extent">
          <extent>1 file</extent>
        </physdesc>
        <repository encodinganalog="3.1.2">Hull University Archives</repository>
        <unitid label="Former Reference">U DDH/13</unitid>
        <unitid encodinganalog="3.1.1" label="Reference" countrycode="GB" repositorycode="050">U DDH/13</unitid>
      </did>
      <scopecontent encodinganalog="3.3.1"><p>Includes statements, constitution and correspondence</p></scopecontent>
    </c>
  END13
end

def item_14
  <<-END14
    <c level="item">
      <did>
        <unittitle encodinganalog="3.1.2">Photocopy. Revolutionary Communist Party </unittitle>
        <unitdate datechar="creation" encodinganalog="3.1.3.2" label="Creation Dates" type="inclusive" normal="1944-1946">1944-1946</unitdate>
        <physdesc encodinganalog="3.4.4" label="Extent">
          <extent>1 file</extent>
        </physdesc>
        <repository encodinganalog="3.1.2">Hull University Archives</repository>
        <unitid label="Former Reference">U DDH/14 former</unitid>
        <unitid encodinganalog="3.1.1" label="Reference" countrycode="GB" repositorycode="050">U DDH/14</unitid>
      </did>
      <scopecontent encodinganalog="3.3.1"><p>Includes internal documents, bulletins and correspondence</p></scopecontent>
    </c>
  END14
end

def two_items
  "<ead>" + item_13 + item_14 + "</ead>"
end

