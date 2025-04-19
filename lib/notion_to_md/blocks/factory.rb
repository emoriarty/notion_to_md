# frozen_string_literal: true

class NotionToMd
  module Blocks
    # === NotionToMd::Blocks::Factory
    #
    # Factory class to create block instances based on the block type
    class Factory
      # rubocop:disable Metrics/MethodLength
      def self.build(block:, children: [])
        case block.type.to_sym
        when :table
          TableBlock.new(block: block, children: children)
        when :table_row
          TableRowBlock.new(block: block, children: children)
        when :bulleted_list_item
          BulletedListItemBlock.new(block: block, children: children)
        when :numbered_list_item
          NumberedListItemBlock.new(block: block, children: children)
        when :to_do
          ToDoListItemBlock.new(block: block, children: children)
        else
          Blocks::Block.new(block: block, children: children)
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
