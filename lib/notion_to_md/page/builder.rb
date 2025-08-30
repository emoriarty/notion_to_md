# frozen_string_literal: true

class NotionToMd
  class Page
    # === NotionToMd::Page::Builder
    #
    # Builds a tree of Notion blocks for a given block (or page) ID by
    # fetching children from the Notion API and recursively traversing
    # blocks that are allowed to contain nested children.
    #
    # @example Build all blocks for a page
    #   notion = Notion::Client.new(token: ENV["NOTION_TOKEN"])
    #   blocks = NotionToMd::Page::Builder.call(block_id: "xxxx-xxxx", notion_client: notion)
    #   blocks # => [NotionToMd::Blocks::Block, ...]
    #
    # @see NotionToMd::Blocks::Factory
    # @see NotionToMd::Blocks::Normalizer
    class Builder
      include Support::Pagination

      # Block types allowed to have nested blocks (children).
      #
      # @return [Array<Symbol>]
      BLOCKS_WITH_PERMITTED_CHILDREN = %i[
        bulleted_list_item
        numbered_list_item
        paragraph
        to_do
        table
      ].freeze

      class << self
        # Build the block tree from a starting block ID.
        #
        # @param block_id [String] The Notion block (or page) ID to expand.
        # @param notion_client [Notion::Client] Initialized Notion client.
        #
        # @return [Array<NotionToMd::Blocks::Block>] Normalized, possibly nested blocks.
        #
        # @see .build
        def call(block_id:, notion_client:)
          new(block_id: block_id, notion_client: notion_client).call
        end

        # @!method build(...)
        #   Alias of {.call}.
        alias build call
      end

      # @return [String] The root block (or page) ID to expand.
      attr_reader :block_id

      # @return [Notion::Client] The Notion API client.
      attr_reader :notion_client

      # Create a new builder.
      #
      # @param block_id [String] The Notion block (or page) ID to expand.
      # @param notion_client [Notion::Client] Initialized Notion client.
      def initialize(block_id:, notion_client:)
        @block_id = block_id
        @notion_client = notion_client
      end

      # Fetch, build, and normalize the full block tree.
      #
      # Recursively expands children for block types listed in
      # {BLOCKS_WITH_PERMITTED_CHILDREN}. Uses {#fetch_blocks} to page through
      # results via `has_more` / `next_cursor`.
      #
      # @return [Array<NotionToMd::Blocks::Block>] Normalized blocks ready for rendering.
      def call
        notion_blocks = fetch_blocks
        blocks = notion_blocks.map do |block|
          children = if permitted_children_for?(block: block)
                       self.class.call(block_id: block.id, notion_client: notion_client)
                     else
                       []
                     end
          Blocks::Factory.build(block: block, children: children)
        end

        Blocks::Normalizer.call(blocks: blocks)
      end

      # Whether a block can have (and actually has) children to be traversed.
      #
      # @param block [Notion::Messages::Message] A Notion block message.
      #
      # @return [Boolean] True if the block type allows children and `has_children` is truthy.
      def permitted_children_for?(block:)
        BLOCKS_WITH_PERMITTED_CHILDREN.include?(block.type.to_sym) && block.has_children
      end

      # Fetch all direct children for {#block_id}, handling Notion pagination.
      #
      # @note This method loops until `has_more` is false, following `next_cursor`.
      #
      # @return [Array<Notion::Messages::Message>] Raw Notion block messages.
      def fetch_blocks
        params = {}

        paginate do |cursor|
          params[:block_id] = block_id
          params[:start_cursor] = cursor if cursor

          notion_client.block_children(params)
        end
      end
    end
  end
end
