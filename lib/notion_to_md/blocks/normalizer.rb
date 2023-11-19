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

      attr_reader :blocks

      def initialize(blocks:)
        @blocks = blocks
      end

      def normalize
        normalize_for :bulleted_list_item
        normalize_for :numbered_list_item
        normalize_for :to_do
      end

      private

      def normalized_blocks
        @normalized_blocks ||= blocks.clone
      end

      def normalize_for(type)
        new_blocks = []

        normalized_blocks.each do |block|
          if block.type.to_sym == type
            blocks_to_normalize << block
          else
            if blocks_to_normalize.any?
              new_blocks << new_block_for(type, children: blocks_to_normalize)
              reset_blocks_to_normalize
            end
            new_blocks << block
          end
        end

        normalized_blocks = new_blocks
      end

      def blocks_to_normalize
        @blocks_to_normalize ||= []
      end

      def reset_blocks_to_normalize
        @blocks_to_normalize = []
      end

      def new_block_for(type, children:)
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
