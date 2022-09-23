# frozen_string_literal: true

module NotionToMd
  module Blocks
    class TableBlock < Block
      def to_md
        table = markdownify_children(0)

        table_header = table[0]
        table_aligment = markdownify_aligment
        table_body = table[1..table.size]

        [table_header, table_aligment, table_body.join("\n")].compact.join("\n")
      end

      private

      def row_size
        @row_size ||= children.first.block.table_row.cells.size
      end

      def markdownify_aligment
        "|#{row_size.times.map { '---' }.join('|')}|" if block.table.has_column_header
      end
    end
  end
end
