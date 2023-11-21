# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::NumberedListBlock) do
  describe('#to_md') do
    let(:children) do
      create_item = lambda do |index|
        list_item = Hashie::Mash.new(
          type: 'numbered_list_item',
          rich_text: [{ plain_text: "item #{index}", type: 'text', href: nil, annotations: {} }]
        )
      end
      3.times.map { |index| NotionToMd::Blocks::NumberedListItemBlock.new(block: create_item.call(index)) }
    end

    it do
      table = described_class.new(children: children)
      expected_output = "1. item 0\n2. item 1\n3. item 2\n\n"

      expect(table.to_md).to eq(expected_output)
    end

    context 'with a nested list' do
      let(:parent_list) do
        raw_list_item = Hashie::Mash.new(
          type: 'numbered_list_item',
          rich_text: [{ plain_text: 'item A', type: 'text', href: nil, annotations: {} }]
        )
        [
          NotionToMd::Blocks::NumberedListItemBlock.new(
            block: raw_list_item,
            children: [NotionToMd::Blocks::NumberedListBlock.new(children: children)]
          )
        ]
      end

      it do
        table = described_class.new(children: parent_list)
        expected_output = "1. item A\n\t1. item 0\n\t2. item 1\n\t3. item 2\n\n"

        expect(table.to_md).to eq(expected_output)
      end
    end
  end
end
