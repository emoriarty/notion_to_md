# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::NumberedListBlock) do
  def create_mash(index)
    Hashie::Mash.new(
      type: 'numbered_list_item',
      numbered_list_item: {
        rich_text: [{ plain_text: "item #{index}", type: 'text', href: nil, annotations: {} }]
      }
    )
  end

  describe('#to_md') do
    let(:children) do
      3.times.map { |index| NotionToMd::Blocks::NumberedListItemBlock.new(block: create_mash(index)) }
    end

    it do
      table = described_class.new(children: children)
      expected_output = "1. item 0\n2. item 1\n3. item 2\n\n"

      expect(table.to_md).to eq(expected_output)
    end

    context 'with a nested list' do
      let(:parent) do
        [
          NotionToMd::Blocks::NumberedListItemBlock.new(
            block: create_mash('A'),
            children: [described_class.new(children: children)]
          )
        ]
      end

      it do
        table = described_class.new(children: parent)
        expected_output = "1. item A\n\t1. item 0\n\t2. item 1\n\t3. item 2\n\n"

        expect(table.to_md).to eq(expected_output)
      end
    end

    context 'with a second nested level' do
      let(:nested_children) do
        3.times.map { |index|
          NotionToMd::Blocks::NumberedListItemBlock.new(
            block: create_mash("#{index}0"),
            children: [described_class.new(children: children)]
          )
        }
      end
      let(:parent) do
        [
          NotionToMd::Blocks::NumberedListItemBlock.new(
            block: create_mash('A'),
            children: [described_class.new(children: nested_children)]
          ),
          NotionToMd::Blocks::NumberedListItemBlock.new(
            block: create_mash('α'),
            children: [described_class.new(children: nested_children)]
          )
        ]
      end

      it do
        table = described_class.new(children: parent)
        expected_output = "1. item A\n\t1. item 00\n\t\t1. item 0\n\t\t2. item 1\n\t\t3. item 2\n\t2. item 10\n\t\t1. item 0\n\t\t2. item 1\n\t\t3. item 2\n\t3. item 20\n\t\t1. item 0\n\t\t2. item 1\n\t\t3. item 2\n2. item α\n\t1. item 00\n\t\t1. item 0\n\t\t2. item 1\n\t\t3. item 2\n\t2. item 10\n\t\t1. item 0\n\t\t2. item 1\n\t\t3. item 2\n\t3. item 20\n\t\t1. item 0\n\t\t2. item 1\n\t\t3. item 2\n\n"

        expect(table.to_md).to eq(expected_output)
      end
    end
  end
end
