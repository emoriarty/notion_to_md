# frozen_string_literal: true

class NotionToMd
  module Blocks
    class TableBlock < Block
      def to_md
        table = markdownify_children(0)

        table_header = table[0]
        table_aligment = markdownify_aligment
        table_body = table[1..table.size]

        [table_header, table_aligment, table_body].compact.join + newline
      end

      protected

      def row_size
        @row_size ||= children.first.block.table_row.cells.size
      end

      def markdownify_aligment
        "|#{row_size.times.map { '---' }.join('|')}|\n" if block.table.has_column_header
      end

      def newline
        "\n"
      end
    end
  end
end
