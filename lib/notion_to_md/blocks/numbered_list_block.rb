# frozen_string_literal: true

class NotionToMd
  module Blocks
    class NumberedListBlock < BulletedListBlock
      def type
        'numbered_list'
      end

      protected

      def markdownify_children(tab_width)
        children.map.with_index do |nested_block, index|
          nested_block.to_md(tab_width: tab_width, index: index + 1)
        end
      end
    end
  end
end
