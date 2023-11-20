# frozen_string_literal: true

module NotionToMd
  module Blocks
    class ToDoListItemBlock < Block
      def newline
        "\n"
      end
    end
  end
end
