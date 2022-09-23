module NotionToMd
  module Blocks
    class Factory
      def self.build(block:, children: [])
        case block.type.to_sym
        when :table
          TableBlock.new(block: block, children: children)
        else
          Blocks::Block.new(block: block, children: children)
        end
      end
    end
  end
end
