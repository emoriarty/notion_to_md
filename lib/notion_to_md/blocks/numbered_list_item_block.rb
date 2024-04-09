# frozen_string_literal: true

require_relative './bulleted_list_item_block'

class NotionToMd
  module Blocks
    class NumberedListItemBlock < BulletedListItemBlock
      # === Parameters:
      # tab_width::
      #  The number of tabs used to indent the block.
      # index::
      #  The index of the block in its parent's children array used to number the item.
      #
      # === Returns
      # The current block (and its children) converted to a markdown string.
      #
      def to_md(tab_width: 0, index: nil)
        md = Types.numbered_list_item(block[block.type.to_sym], index) + newline
        md + build_nested_blocks(tab_width + 1)
      rescue NoMethodError
        Logger.info("Unsupported block type: #{block.type}")
        nil
      end
    end
  end
end
