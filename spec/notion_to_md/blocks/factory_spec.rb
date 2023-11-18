# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::Factory) do
  describe('.build') do
    context 'when using a common block' do
      let(:block_mash) do
        Hashie::Mash.new(
          type: 'dummy_type'
        )
      end

      it do
        output = described_class.build(block: block_mash)

        expect(output).to be_an_instance_of(NotionToMd::Blocks::Block)
      end
    end

    context 'when using a table block' do
      let(:block_mash) do
        Hashie::Mash.new(
          type: 'table'
        )
      end

      it do
        output = described_class.build(block: block_mash)

        expect(output).to be_an_instance_of(NotionToMd::Blocks::TableBlock)
      end
    end

    context 'when using a to_do block' do
      let(:block_mash) do
        Hashie::Mash.new(
          type: 'to_do'
        )
      end

      it do
        output = described_class.build(block: block_mash)

        expect(output).to be_an_instance_of(NotionToMd::Blocks::ToDoRowBlock)
      end
    end

    context 'when using a bulleted_list_item block' do
      let(:block_mash) do
        Hashie::Mash.new(
          type: 'bulleted_list_item'
        )
      end

      it do
        output = described_class.build(block: block_mash)

        expect(output).to be_an_instance_of(NotionToMd::Blocks::BulletedListItemBlock)
      end
    end

    context 'when using a numbered_list_item block' do
      let(:block_mash) do
        Hashie::Mash.new(
          type: 'numbered_list_item'
        )
      end

      it do
        output = described_class.build(block: block_mash)

        expect(output).to be_an_instance_of(NotionToMd::Blocks::BulletedListItemBlock)
      end
    end

    context 'when using a table_row block' do
      let(:block_mash) do
        Hashie::Mash.new(
          type: 'table_row'
        )
      end

      it do
        output = described_class.build(block: block_mash)

        expect(output).to be_an_instance_of(NotionToMd::Blocks::TableRowBlock)
      end
    end
  end
end
