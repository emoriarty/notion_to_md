# frozen_string_literal: true

class NotionToMd
  module Blocks
    # === NotionToMd::Blocks::Builder
    #
    # This class is responsible for building a tree of blocks from the Notion API.
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

      # === Parameters
      # block_id::
      #   A string representing a notion block id .
      # notion_client::
      #   An Notion::Client object
      #
      # === Returns
      # An array of NotionToMd::Blocks::Block.
      #
      def self.call(block_id:, notion_client:)
        new(block_id: block_id, notion_client: notion_client).call
      end

      attr_reader :block_id, :notion_client

      # === Parameters
      # block_id::
      #   A string representing a notion block id .
      # notion_client::
      #   An Notion::Client object
      #
      # === Returns
      # An array of NotionToMd::Blocks::Block.
      #
      def initialize(block_id:, notion_client:)
        @block_id = block_id
        @notion_client = notion_client
      end

      # === Parameters
      #
      # === Returns
      # An array of NotionToMd::Blocks::Block.
      #
      def call
        notion_blocks = fetch_blocks
        blocks = notion_blocks.map do |block|
          children = if Builder.permitted_children_for?(block: block)
                       Builder.new(block_id: block.id, &fetch_blocks).build
                     else
                       []
                     end
          Factory.build(block: block, children: children)
        end

        Normalizer.normalize(blocks: blocks)
      end

      # === Parameters
      # block_id::
      #   A string representing a notion block id.
      #
      # === Returns
      # An array of Notion::Messages::Message.
      #
      def fetch_blocks
        all_results  = []
        start_cursor = nil

        loop do
          params = { block_id: block_id }
          params[:start_cursor] = start_cursor if start_cursor

          resp = notion_client.block_children(params)

          all_results.concat(resp.results)

          break unless resp.has_more && resp.next_cursor

          start_cursor = resp.next_cursor
        end

        all_results
      end
    end
  end
end
