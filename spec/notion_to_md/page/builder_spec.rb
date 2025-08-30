# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Page::Builder) do
  let(:notion_client) { Notion::Client.new(token: ENV.fetch('NOTION_TOKEN', nil)) }
  let(:page_id) { '25adb135281c80828cb1dc59437ae243' }

  describe('#permitted_children_for?') do
    let(:builder) { described_class.new(block_id: page_id, notion_client: notion_client) }

    context('when has children and is permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: true, type: 'numbered_list_item') }

      it { expect(builder.permitted_children_for?(block: block_notion)).to be(true) }
    end

    context('when has children and is not permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: true, type: 'not_permitted_block') }

      it { expect(builder.permitted_children_for?(block: block_notion)).to be(false) }
    end

    context('when has no children and is not permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: false, type: 'not_permitted_block') }

      it { expect(builder.permitted_children_for?(block: block_notion)).to be(false) }
    end

    context('when has no children and is permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: false, type: 'numbered_list_item') }

      it { expect(builder.permitted_children_for?(block: block_notion)).to be(false) }
    end

    %w[bulleted_list_item numbered_list_item paragraph table to_do].each do |type|
      context "when #{type}" do
        let(:block) { Hashie::Mash.new(type: type, has_children: true) }

        it { expect(builder.permitted_children_for?(block: block)).to be(true) }
      end
    end
  end

  describe('.call') do
    before do
      VCR.insert_cassette('a_very_long_notion_page')
    end

    after do
      VCR.eject_cassette('a_very_long_notion_page')
    end

    it 'returns a list of NotionToMd::Blocks::Block' do
      output = described_class.call(block_id: page_id, notion_client: notion_client)
      expect(output).to all(be_an(NotionToMd::Blocks::Block))
    end

    it 'returned list with no children' do
      output = described_class.call(block_id: page_id, notion_client: notion_client)
      expect(output).to include(an_object_having_attributes(children: []))
    end
  end
end
