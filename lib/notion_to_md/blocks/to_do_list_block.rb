# frozen_string_literal: true

class NotionToMd
  module Blocks
    class ToDoListBlock < BulletedListBlock
      def type
        'to_do_list'
      end
    end
  end
end
