# frozen_string_literal: true

require 'forwardable'

class NotionToMd
  module Blocks
    # === NotionToMd::Blocks::Block
    #
    # This class is responsible for converting Notion blocks to markdown.
    class Block
      extend Forwardable

      attr_reader :block, :children

      def_delegators :block, :type

      # === Parameters:
      # block::
      #   A {Notion::Messages::Message}[https://github.com/orbit-love/notion-ruby-client/blob/main/lib/notion/messages/message.rb] object.
      # children::
      #   An array of NotionToMd::Block::Block objects.
      #
      # === Returns
      # A Block object.
      #
      def initialize(block:, children: [])
        @block = block
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
        block_type = block.type.to_sym
        md = Types.send(block_type, block[block_type]) + newline
        md + build_nested_blocks(tab_width + 1)
      rescue NoMethodError
        Logger.info("Unsupported block type: #{block_type}")
        nil
      end

      protected

      def newline
        "\n\n"
      end

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
          "#{"\t" * tab_width}#{md}"
        end
      end
    end
  end
end
