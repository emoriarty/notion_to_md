# frozen_string_literal: true

module NotionToMd
  module Blocks
    class Factory
      def self.build(block:, children: [])
        case block.type.to_sym
        when :table
          TableBlock.new(block: block, children: children)
        when :table_body
          TableRowBlock.new(block: block, children: children)
        when :bulleted_list_item, :numbered_list_item
          BulletedListItemBlock.new(block: block, children: children)
        else
          Blocks::Block.new(block: block, children: children)
        end
      end
    end
  end
end
