# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NotionToMd::Database do
  subject(:db) { described_class.call(database_id: database_id, notion_client: notion_client) }

  let(:database_id) { '1ae33dd5f3314402948069517fa40ae2' }
  let(:notion_client) { Notion::Client.new(token: ENV.fetch('NOTION_TOKEN', nil)) }

  before { VCR.insert_cassette('a_database') }
  after  { VCR.eject_cassette('a_database') }

  describe '.call' do
    it 'returns a NotionToMd::Database' do
      expect(db).to be_a(described_class)
    end
  end

  describe '.build' do
    it 'is an alias of .call' do
      expect(described_class.method(:build)).to eq(described_class.method(:call))
    end
  end

  describe '#pages' do
    it 'returns an Array' do
      expect(db.pages).to be_a(Array)
    end

    it 'is not empty' do
      expect(db.pages).not_to be_empty
    end

    it 'contains objects responding to #id' do
      expect(db.pages.first).to respond_to(:id)
    end

    it 'only contains NotionToMd::Page objects' do
      expect(db.pages).to all(be_a(NotionToMd::Page))
    end
  end

  describe 'delegated methods' do
    describe '.properties' do
      it 'is delegated and responds to #properties' do
        expect(db).to respond_to(:properties)
      end

      it 'returns a Hash' do
        expect(db.properties).to be_a(Hash)
      end

      it 'has String keys' do
        expect(db.properties.keys).to all(be_a(String))
      end

      it 'has Hash values' do
        expect(db.properties.values).to all(be_a(Hash))
      end
    end
  end

  context 'with an empty database' do
    let(:database_id) { '25edb135281c80a3ab0dd768411cd25e' }

    before { VCR.insert_cassette('empty_database') }
    after  { VCR.eject_cassette('empty_database') }

    it 'returns a NotionToMd::Database' do
      expect(db).to be_a(described_class)
    end

    it 'has metadata' do
      expect(db.metadata).to be_present
    end

    it 'returns an empty pages array' do
      expect(db.pages).to eq([])
    end
  end

  context 'when database does not exist' do
    # Override the shared subject's database_id
    let(:database_id) { 'unknown' }

    before { VCR.insert_cassette('unknown_database') }
    after  { VCR.eject_cassette('unknown_database') }

    it 'raises a Notion API error' do
      expect { db }.to raise_error(Notion::Api::Errors::ObjectNotFound)
    end
  end
end
