# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::TableBlock) do
  describe('#to_md') do
    let(:has_column_header) { false }

    let(:table_block_mash) do
      Hashie::Mash.new(
        type: 'table',
        table: Hashie::Mash.new(
          has_column_header: has_column_header
        )
      )
    end

    let(:children) do
      table_row = Hashie::Mash.new(
        type: 'table_row',
        table_row: {
          cells: [
            [{ plain_text: 'cell 1', type: 'text', href: nil, annotations: {} }],
            [{ plain_text: 'cell 2', type: 'text', href: nil, annotations: {} }],
            [{ plain_text: 'cell 3', type: 'text', href: nil, annotations: {} }]
          ]
        }
      )
      3.times.map { NotionToMd::Blocks::TableRowBlock.new(block: table_row) }
    end

    it "" do
      table = described_class.new(block: table_block_mash, children: children)
      expected_output = "|cell 1|cell 2|cell 3|\n|cell 1|cell 2|cell 3|\n|cell 1|cell 2|cell 3|\n\n"

      expect(table.to_md).to eq(expected_output)
    end

    context 'with column header' do
      let(:has_column_header) { true }

      it do
        table = described_class.new(block: table_block_mash, children: children)
        expected_output = "|cell 1|cell 2|cell 3|\n|---|---|---|\n|cell 1|cell 2|cell 3|\n|cell 1|cell 2|cell 3|\n\n"

        expect(table.to_md).to eq(expected_output)
      end
    end
  end
end
