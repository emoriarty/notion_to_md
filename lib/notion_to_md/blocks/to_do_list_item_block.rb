# frozen_string_literal: true

require_relative './bulleted_list_item_block'

class NotionToMd
  module Blocks
    class ToDoListItemBlock < BulletedListItemBlock
      def newline
        "\n"
      end
    end
  end
end
