# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NotionToMd::Page do
  subject(:page) { described_class.call(id: page_id, notion_client: notion_client, frontmatter: frontmatter) }

  let(:page_id) { '25adb135281c80828cb1dc59437ae243' }
  let(:notion_client) { Notion::Client.new(token: ENV.fetch('NOTION_TOKEN', nil)) }
  let(:frontmatter) { false }

  before { VCR.insert_cassette('a_very_long_notion_page') }
  after  { VCR.eject_cassette('a_very_long_notion_page') }

  it_behaves_like 'a callable interface'

  describe '#blocks (alias: #children)' do
    it 'returns an Array' do
      expect(page.blocks).to be_a(Array)
    end

    it 'contains elements that respond to #to_md' do
      expect(page.blocks).to all(respond_to(:to_md))
    end
  end

  describe '#body' do
    it 'returns a String' do
      expect(page.body).to be_a(String)
    end

    it 'is not empty for this long page cassette' do
      expect(page.body).not_to be_empty
    end
  end

  describe '#to_s' do
    it 'returns the markdown content' do
      expect(page.to_s)
        .to start_with("\nLorem ipsum dolor sit amet")
        .and end_with("tempor nec odio.\n\n\n")
    end

    it 'does not include frontmatter' do
      expect(page.to_s).to start_with("\n")
    end

    context('with frontmatter enabled') do
      let(:frontmatter) { true }

      it 'returns the markdown content with frontmatter' do
        expect(page.to_s)
          .to start_with('---')
          .and end_with("tempor nec odio.\n\n\n")
      end
    end
  end

  describe '#to_md' do
    it 'returns the markdown content' do
      expect(page.to_md)
        .to start_with("\nLorem ipsum dolor sit amet")
        .and end_with("tempor nec odio.\n\n\n")
    end

    it 'does not include frontmatter' do
      expect(page.to_md).to start_with("\n")
    end

    context('with frontmatter enabled') do
      let(:frontmatter) { true }

      it 'returns the markdown content with frontmatter' do
        expect(page.to_md)
          .to start_with('---')
          .and end_with("tempor nec odio.\n\n\n")
      end
    end
  end

  describe 'delegated/read-through metadata methods' do
    describe '#properties' do
      it 'responds to #properties (delegated)' do
        expect(page).to respond_to(:properties)
      end

      it 'returns a Hash with String keys and Hash values' do
        expect(page.properties).to be_a(Hash)
        expect(page.properties.keys).to all(be_a(String))
        expect(page.properties.values).to all(be_a(Hash))
      end
    end

    describe '#title' do
      it { expect(page.title).to eq('A very long document') }
    end

    describe '#id' do
      it { expect(page.id).to eq('25adb135281c80828cb1dc59437ae243') }
    end

    describe '#created_time' do
      it { expect(page.created_time).to eq('2025-08-25T18:14:00.000Z') }
    end

    describe '#url' do
      it { expect(page.url).to eq('https://www.notion.so/A-very-long-document-25adb135281c80828cb1dc59437ae243') }
    end

    describe '#archived' do
      it { expect(page.archived).to be(false) }
    end

    describe '#cover' do
      it { expect(page.cover).to eq('https://www.notion.so/images/page-cover/rijksmuseum_jansz_1641.jpg') }
    end

    describe '#icon' do
      it { expect(page.icon).to eq('✈️') }
    end

    describe '#last_edited_time' do
      it { expect(page.last_edited_time).to eq('2025-08-30T05:11:00.000Z') }
    end

    describe '#last_edited_by_object' do
      it { expect(page.last_edited_by_object).to eq('user') }
    end

    describe '#last_edited_by_id' do
      it { expect(page.last_edited_by_id).to eq('db313571-0280-411f-a6de-70e826421d12') }
    end
  end

  context 'when page does not exist' do
    let(:page_id) { 'unknown' }

    before { VCR.insert_cassette('unknown_page') }
    after  { VCR.eject_cassette('unknown_page') }

    it 'raises a Notion API error' do
      expect { page }.to raise_error(Notion::Api::Errors::NotionError)
    end
  end
end
