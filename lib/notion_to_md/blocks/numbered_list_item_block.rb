# frozen_string_literal: true

module NotionToMd
  module Blocks
    class NumberedListItemBlock < Block
      def newline
        "\n"
      end
    end
  end
end
