# frozen_string_literal: true

module NotionToMd
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
        build_nested_blocks(tab_width)
      end

      def type
        "bulleted_list"
      end
    end
  end
end
