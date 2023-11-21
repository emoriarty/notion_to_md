# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::BulletedListBlock) do
  describe('#to_md') do
    let(:children) do
      create_item = lambda do |index|
        list_item = Hashie::Mash.new(
          type: 'bulleted_list_item',
          bulleted_list_item: {
            rich_text: [{ plain_text: "item #{index}", type: 'text', href: nil, annotations: {} }]
          }
        )
      end
      3.times.map { |index| NotionToMd::Blocks::BulletedListItemBlock.new(block: create_item.call(index)) }
    end

    it do
      table = described_class.new(children: children)
      expected_output = "- item 0\n- item 1\n- item 2\n\n"

      expect(table.to_md).to eq(expected_output)
    end

    context 'with a nested list' do
      let(:parent_list) do
        raw_list_item = Hashie::Mash.new(
          type: 'bulleted_list_item',
          bulleted_list_item: {
            rich_text: [{ plain_text: 'item A', type: 'text', href: nil, annotations: {} }]
          }
        )
        [
          NotionToMd::Blocks::BulletedListItemBlock.new(
            block: raw_list_item,
            children: [NotionToMd::Blocks::BulletedListBlock.new(children: children)]
          )
        ]
      end

      it do
        table = described_class.new(children: parent_list)
        expected_output = "- item A\n\t- item 0\n\t- item 1\n\t- item 2\n\n"

        expect(table.to_md).to eq(expected_output)
      end
    end

    context 'with a second nesting level' do
      let(:nested_children) do
        create_item = lambda do |index|
          list_item = Hashie::Mash.new(
            type: 'bulleted_list_item',
            bulleted_list_item: {
              rich_text: [{ plain_text: "item #{index}", type: 'text', href: nil, annotations: {} }]
            }
          )
        end
        3.times.map { |index| NotionToMd::Blocks::BulletedListItemBlock.new(
          block: create_item.call(index * 10),
          children: [NotionToMd::Blocks::BulletedListBlock.new(children: children)]
        ) }
      end
      let(:parent_list) do
        first_list_item = Hashie::Mash.new(
          type: 'bulleted_list_item',
          bulleted_list_item: {
            rich_text: [{ plain_text: 'item A', type: 'text', href: nil, annotations: {} }]
          }
        )
        second_list_item = Hashie::Mash.new(
          type: 'bulleted_list_item',
          bulleted_list_item: {
            rich_text: [{ plain_text: 'item α', type: 'text', href: nil, annotations: {} }]
          }
        )
        [
          NotionToMd::Blocks::BulletedListItemBlock.new(
            block: first_list_item,
            children: [NotionToMd::Blocks::BulletedListBlock.new(children: nested_children)]
          ),
          NotionToMd::Blocks::BulletedListItemBlock.new(
            block: second_list_item,
            children: [NotionToMd::Blocks::BulletedListBlock.new(children: nested_children)]
          )
        ]
      end

      it do
        table = described_class.new(children: parent_list)
        expected_output = "- item A\n\t- item 0\n\t\t- item 0\n\t\t- item 1\n\t\t- item 2\n\t- item 10\n\t\t- item 0\n\t\t- item 1\n\t\t- item 2\n\t- item 20\n\t\t- item 0\n\t\t- item 1\n\t\t- item 2\n- item α\n\t- item 0\n\t\t- item 0\n\t\t- item 1\n\t\t- item 2\n\t- item 10\n\t\t- item 0\n\t\t- item 1\n\t\t- item 2\n\t- item 20\n\t\t- item 0\n\t\t- item 1\n\t\t- item 2\n\n"

        expect(table.to_md).to eq(expected_output)
      end
    end
  end
end
