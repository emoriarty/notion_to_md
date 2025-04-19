# frozen_string_literal: true

class NotionToMd
  module Blocks
    # === NotionToMd::Blocks::Normalizer
    #
    # This class is responsible for normalizing blocks of the same type
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
          if block_of_type?(block, type)
            blocks_to_normalize << block
          else
            # When we encounter a block that is not of the provided type,
            # we need to normalize the blocks we've collected so far.
            # Then we add the current block to the new blocks array.
            # This is to keep the order of the blocks as they are in the original array.
            flush_blocks_to_normalize_into(new_blocks, type)
            new_blocks << block
          end
        end

        # If the last block is the provided type, it won't be added to the new blocks array.
        # So, we need to normalize the blocks we've collected so far.
        flush_blocks_to_normalize_into(new_blocks, type)

        normalized_blocks.replace(new_blocks)
      end

      private

      def block_of_type?(block, type)
        block.type.to_sym == type
      end

      def flush_blocks_to_normalize_into(new_blocks, type)
        return if blocks_to_normalize.empty?

        new_blocks << new_block_and_reset_blocks_to_normalize(type)
      end

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
