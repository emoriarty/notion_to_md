# frozen_string_literal: true

class NotionToMd
  module Blocks
    # === NotionToMd::Blocks::Factory
    #
    # Factory class for instantiating the correct block wrapper class
    # depending on the Notion block type.
    #
    # This is used by {NotionToMd::Page::Builder} when traversing Notion
    # blocks returned from the API.
    #
    # @example Build a block instance from a Notion API message
    #   block = notion_client.block_children(block_id: "xxxx").results.first
    #   instance = NotionToMd::Blocks::Factory.build(block: block)
    #   instance # => NotionToMd::Blocks::Block subclass
    #
    # @see NotionToMd::Blocks::Block
    # @see NotionToMd::Page::Builder
    class Factory
      class << self
        # Build the appropriate block wrapper.
        #
        # @param block [Notion::Messages::Message]
        #   A Notion block message from the API.
        # @param children [Array<NotionToMd::Blocks::Block>]
        #   Optional nested block instances.
        #
        # @return [NotionToMd::Blocks::Block]
        #   A block instance of the corresponding subclass:
        #
        #   * {TableBlock} for `:table`
        #   * {TableRowBlock} for `:table_row`
        #   * {BulletedListItemBlock} for `:bulleted_list_item`
        #   * {NumberedListItemBlock} for `:numbered_list_item`
        #   * {ToDoListItemBlock} for `:to_do`
        #   * {NotionToMd::Blocks::Block} for all others
        #
        # @note Custom block classes must implement `#to_md`.
        def call(block:, children: [])
          case block.type.to_sym
          when :table
            TableBlock.new(block: block, children: children)
          when :table_row
            TableRowBlock.new(block: block, children: children)
          when :bulleted_list_item
            BulletedListItemBlock.new(block: block, children: children)
          when :numbered_list_item
            NumberedListItemBlock.new(block: block, children: children)
          when :to_do
            ToDoListItemBlock.new(block: block, children: children)
          else
            Blocks::Block.new(block: block, children: children)
          end
        end

        alias build call
      end
    end
  end
end
