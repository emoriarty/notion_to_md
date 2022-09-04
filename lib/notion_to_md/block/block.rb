# frozen_string_literal: true

require 'forwardable'

module NotionToMd
  module Block
    class Block
      extend Forwardable

      attr_reader :block

      def_delegators :block, :has_children, :children

      # === Parameters:
      # block::
      #   A {Notion::Messages::Message}[https://github.com/orbit-love/notion-ruby-client/blob/main/lib/notion/messages/message.rb] object.
      #
      # === Returns
      # A Block object.
      #
      def initialize(block:)
        @block = block
      end

      # === Parameters:
      # tab_width::
      #  The number of tabs used to indent the block.
      #
      # === Returns
      # The current block (and its children) converted to a markdown string.
      #
      def to_md(tab_width: 0)
        block_type = block.type.to_sym
        md = Types.send(block_type, block[block_type])
        md += build_nested_blocks(tab_width + 1) if has_children
        md
      rescue StandardError
        Logger.info("Unsupported block type: #{block_type}")
        nil
      end

      private

      def build_nested_blocks(tab_width)
        mds = markdownify_children(tab_width).compact
        indent_children(mds, tab_width).join
      end

      def markdownify_children(tab_width)
        children.map do |nested_block|
          nested_block.to_md(tab_width: tab_width)
        end
      end

      def indent_children(mds, tab_width)
        mds.map do |md|
          "\n\n#{"\t" * tab_width}#{md}"
        end
      end
    end
  end
end
