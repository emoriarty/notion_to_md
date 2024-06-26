# frozen_string_literal: true

class NotionToMd
  module Blocks
    class BulletedListBlock < Block
      def initialize(children: [])
        @children = children
      end

      # === Parameters:
      # tab_width::
      #  The number of tabs used to indent the block.
      #
      # === Returns
      # The current block (and its children) converted to a markdown string.
      #
      def to_md(tab_width: 0)
        if tab_width.zero?
          build_nested_blocks(tab_width) + newline
        else
          build_nested_blocks(tab_width)
        end
      end

      def type
        'bulleted_list'
      end

      def newline
        "\n"
      end
    end
  end
end
