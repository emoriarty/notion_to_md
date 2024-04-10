# frozen_string_literal: true

class NotionToMd
  module Blocks
    class TableRowBlock < Block
      def newline
        "\n"
      end
    end
  end
end
