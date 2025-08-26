# frozen_string_literal: true

class NotionToMd
  module Blocks
    class ToDoListItemBlock < BulletedListItemBlock
      def newline
        "\n"
      end
    end
  end
end
