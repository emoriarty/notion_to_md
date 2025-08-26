# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::ToDoListBlock) do
  def create_mash(index)
    Hashie::Mash.new(
      type: 'to_do',
      to_do: {
        rich_text: [{ plain_text: "item #{index}", type: 'text', href: nil, annotations: {} }]
      }
    )
  end

  describe('#to_md') do
    let(:children) do
      3.times.map { |index| NotionToMd::Blocks::ToDoListItemBlock.new(block: create_mash(index)) }
    end

    it do
      table = described_class.new(children: children)
      expected_output = "- [ ] item 0\n- [ ] item 1\n- [ ] item 2\n\n"

      expect(table.to_md).to eq(expected_output)
    end

    context 'with a nested list' do
      let(:parent) do
        [
          NotionToMd::Blocks::ToDoListItemBlock.new(
            block: create_mash('A'),
            children: [described_class.new(children: children)]
          )
        ]
      end

      it do
        table = described_class.new(children: parent)
        expected_output = "- [ ] item A\n\t- [ ] item 0\n\t- [ ] item 1\n\t- [ ] item 2\n\n"

        expect(table.to_md).to eq(expected_output)
      end
    end

    context 'with a second nested level' do
      let(:nested_children) do
        3.times.map { |index| NotionToMd::Blocks::ToDoListItemBlock.new(
          block: create_mash("#{index}0"),
          children: [described_class.new(children: children)]
        )
        }
      end
      let(:parent) do
        [
          NotionToMd::Blocks::ToDoListItemBlock.new(
            block: create_mash('A'),
            children: [described_class.new(children: nested_children)]
          ),
          NotionToMd::Blocks::ToDoListItemBlock.new(
            block: create_mash('α'),
            children: [described_class.new(children: nested_children)]
          )
        ]
      end

      it do
        table = described_class.new(children: parent)
        expected_output = "- [ ] item A\n\t- [ ] item 00\n\t\t- [ ] item 0\n\t\t- [ ] item 1\n\t\t- [ ] item 2\n\t- [ ] item 10\n\t\t- [ ] item 0\n\t\t- [ ] item 1\n\t\t- [ ] item 2\n\t- [ ] item 20\n\t\t- [ ] item 0\n\t\t- [ ] item 1\n\t\t- [ ] item 2\n- [ ] item α\n\t- [ ] item 00\n\t\t- [ ] item 0\n\t\t- [ ] item 1\n\t\t- [ ] item 2\n\t- [ ] item 10\n\t\t- [ ] item 0\n\t\t- [ ] item 1\n\t\t- [ ] item 2\n\t- [ ] item 20\n\t\t- [ ] item 0\n\t\t- [ ] item 1\n\t\t- [ ] item 2\n\n"

        expect(table.to_md).to eq(expected_output)
      end
    end
  end
end
