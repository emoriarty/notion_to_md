# frozen_string_literal: true

module NotionToMd
  module Blocks
    class Builder
      ##
      # Array containing the block types allowed to have nested blocks (children).
      BLOCKS_WITH_PERMITTED_CHILDREN = %i[
        bulleted_list_item
        numbered_list_item
        paragraph
        to_do
        table
      ].freeze

      # === Parameters
      # block::
      #   A {Notion::Messages::Message}[https://github.com/orbit-love/notion-ruby-client/blob/main/lib/notion/messages/message.rb] object.
      #
      # === Returns
      # A boolean indicating if the blocked passed in
      # is permitted to have children based on its type.
      #
      def self.permitted_children_for?(block:)
        BLOCKS_WITH_PERMITTED_CHILDREN.include?(block.type.to_sym) && block.has_children
      end

      attr_reader :block_id, :fetch_blocks

      # === Parameters
      # block_id::
      #   A string representing a notion block id .
      # fetch_blocks::
      #   A block that fetches the blocks from the Notion API.
      #
      # === Returns
      # An array of NotionToMd::Blocks::Block.
      #
      def initialize(block_id:, &fetch_blocks)
        @block_id = block_id
        @fetch_blocks = fetch_blocks
      end

      # === Parameters
      #
      # === Returns
      # An array of NotionToMd::Blocks::Block.
      #
      def build
        notion_messages = fetch_blocks.call(block_id)
        blocks = notion_messages.results.map do |block|
          children = if Builder.permitted_children_for?(block: block)
                       Builder.new(block_id: block.id, &fetch_blocks).build
                     else
                       []
                     end
          Factory.build(block: block, children: children)
        end

        Normalizer.normalize(blocks: blocks)
      end
    end
  end
end
