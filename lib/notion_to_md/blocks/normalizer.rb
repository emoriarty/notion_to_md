# frozen_string_literal: true

class NotionToMd
  module Blocks
    # === NotionToMd::Blocks::Normalizer
    #
    # Responsible for normalizing sequences of adjacent blocks of the same type
    # into grouped list blocks (e.g., multiple consecutive `bulleted_list_item`
    # blocks into a single `BulletedListBlock`).
    #
    # This ensures Markdown output has proper list structures instead of
    # repeated, ungrouped items.
    #
    # @example Normalize a sequence of blocks
    #   blocks = [
    #     BulletedListItemBlock.new(block: block1),
    #     BulletedListItemBlock.new(block: block2),
    #     NotionToMd::Blocks::Block.new(block: block3)
    #   ]
    #
    #   normalized = NotionToMd::Blocks::Normalizer.normalize(blocks: blocks)
    #   # => [BulletedListBlock(children: [..]), Block(..)]
    #
    # @see NotionToMd::Blocks::Block
    # @see NotionToMd::Blocks::Factory
    class Normalizer
      class << self
        # Normalize a list of blocks.
        #
        # @param blocks [Array<NotionToMd::Blocks::Block>]
        #   Raw blocks to normalize.
        #
        # @return [Array<NotionToMd::Blocks::Block>]
        #   Normalized blocks where consecutive list items are grouped.
        def call(blocks:)
          new(blocks: blocks).call
        end
      end

      # @return [Array<NotionToMd::Blocks::Block>]
      #   The mutable, normalized block list.
      attr_reader :normalized_blocks

      # Create a new normalizer.
      #
      # @param blocks [Array<NotionToMd::Blocks::Block>]
      #   Raw blocks to normalize.
      def initialize(blocks:)
        @normalized_blocks = blocks.dup
      end

      # Run normalization for all supported types:
      #
      # * `:bulleted_list_item`
      # * `:numbered_list_item`
      # * `:to_do`
      #
      # @return [Array<NotionToMd::Blocks::Block>]
      #   The final normalized block array.
      def call
        normalize_for :bulleted_list_item
        normalize_for :numbered_list_item
        normalize_for :to_do
        normalized_blocks
      end

      # Normalize consecutive blocks of the given +type+ into a single grouped block,
      # while preserving original order for everything else.
      #
      # The algorithm scans left-to-right, buffering runs of +type+. When a different
      # type appears (or we reach the end), the buffered run is flushed as a grouped
      # block and the non-matching block is appended as-is.
      def normalize_for(type)
        new_blocks = []

        normalized_blocks.each do |block|
          if block_of_type?(block, type)
            # Accumulate consecutive blocks of the target type
            blocks_to_normalize << block
          else
            # A different type breaks the run:
            # 1) flush the buffered run as a single grouped block
            # 2) append the current (non-matching) block
            flush_blocks_to_normalize_into(new_blocks, type)
            new_blocks << block
          end
        end

        # If the sequence ended with a run of the target type, it hasn’t been
        # emitted yet—flush it now.
        flush_blocks_to_normalize_into(new_blocks, type)

        # Replace the working set with the newly normalized list
        normalized_blocks.replace(new_blocks)
      end

      private

      # @api private
      # @param block [NotionToMd::Blocks::Block]
      # @param type [Symbol]
      # @return [Boolean] true if the block matches the given type.
      def block_of_type?(block, type)
        block.type.to_sym == type
      end

      # @api private
      # Flush accumulated blocks to the new array as a grouped block.
      #
      # @param new_blocks [Array<NotionToMd::Blocks::Block>]
      # @param type [Symbol]
      # @return [void]
      def flush_blocks_to_normalize_into(new_blocks, type)
        return if blocks_to_normalize.empty?

        new_blocks << new_block_and_reset_blocks_to_normalize(type)
      end

      # @api private
      # Create a grouped block and reset buffer.
      #
      # @param type [Symbol]
      # @return [NotionToMd::Blocks::Block]
      def new_block_and_reset_blocks_to_normalize(type)
        new_block = new_block_for(type, blocks_to_normalize)
        @blocks_to_normalize = []
        new_block
      end

      # @api private
      # @return [Array<NotionToMd::Blocks::Block>]
      def blocks_to_normalize
        @blocks_to_normalize ||= []
      end

      # @api private
      # Create a wrapper block (list) depending on type.
      #
      # @param type [Symbol]
      # @param children [Array<NotionToMd::Blocks::Block>]
      # @return [NotionToMd::Blocks::Block]
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
