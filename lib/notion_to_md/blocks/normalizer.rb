# frozen_string_literal: true

module NotionToMd
  module Blocks
    class Normalizer
      # === Parameters
      # blocks::
      #  An array of NotionToMd::Blocks::Block.
      #
      def self.normalize(blocks:)
        new(blocks: blocks).normalize
      end

      attr_reader :normalized_blocks

      def initialize(blocks:)
        @normalized_blocks = blocks.dup
      end

      def normalize
        normalize_for :bulleted_list_item
        normalize_for :numbered_list_item
        normalize_for :to_do
      end

      def normalize_for(type)
        new_blocks = []

        normalized_blocks.each do |block|
          if block.type.to_sym == type
            blocks_to_normalize << block
          else
            # When we encounter a block that is not of the provided type,
            # we need to normalize the blocks we've collected so far.
            # Then we add the current block to the new blocks array.
            # This is because we want to keep the order of the blocks.
            new_blocks << new_block_and_reset_blocks_to_normalize(type) unless blocks_to_normalize.empty?
            new_blocks << block
          end
        end

        # If the last block is the provided type, it won't be added to the new blocks array.
        # So, we need to normalize the blocks we've collected so far.
        new_blocks << new_block_and_reset_blocks_to_normalize(type) unless blocks_to_normalize.empty?

        normalized_blocks.replace(new_blocks)
      end

      private

      def new_block_and_reset_blocks_to_normalize(type)
        new_block = new_block_for(type, blocks_to_normalize)
        @blocks_to_normalize = []
        new_block
      end

      def blocks_to_normalize
        @blocks_to_normalize ||= []
      end

      def new_block_for(type, children)
        case type
        when :bulleted_list_item
          BulletedListBlock.new(children: children)
        when :numbered_list_item
          NumberedListBlock.new(children: children)
        when :to_do
          ToDoListBlock.new(children: children)
        end
      end
    end
  end
end
