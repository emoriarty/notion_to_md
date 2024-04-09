# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Converter) do
  let(:notion_client) { instance_double(Notion::Client) }
  let(:token) { 'secret_token' }
  let(:page_id) { 'page_id' }
  let(:page) { instance_double(NotionToMd::Page, id: page_id) }
  let(:page_blocks) { instance_double(NotionToMd::Blocks) }

  before do
    allow(Notion::Client).to receive(:new).and_return(notion_client)
    allow(notion_client).to receive(:page).with(page_id: page_id).and_return(page)
    allow(NotionToMd::Blocks).to receive(:build).and_return(page_blocks)
    allow(NotionToMd::Page).to receive(:new).with(page: page, blocks: page_blocks).and_return(page)
    allow(page).to receive(:frontmatter).and_return("frontmatter")
    allow(page).to receive(:body).and_return("body")
  end

  describe('#new') do
    it 'creates a new instance of Notion::Client' do
      described_class.new(page_id: page_id, token: token)

      expect(Notion::Client).to have_received(:new).with(token: token)
    end
  end

  describe('#convert') do
    let(:converter) { described_class.new(page_id: page_id) }

    it 'returns the markdown document' do
      expect(converter.convert).to eq("\nbody\n")
    end
  end
end
