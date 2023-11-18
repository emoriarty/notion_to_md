# frozen_string_literal: true

require_relative './blocks/block'
require_relative './blocks/factory'
require_relative './blocks/table_block'
require_relative './blocks/table_row_block'
require_relative './blocks/bulleted_list_item_block'
require_relative './blocks/to_do_block'
require_relative './blocks/types'

module NotionToMd
  module Blocks
    ##
    # Array containing the block types allowed to have nested blocks (children).
    PERMITTED_CHILDREN = [
      Types.method(:bulleted_list_item).name,
      Types.method(:numbered_list_item).name,
      Types.method(:paragraph).name,
      Types.method(:to_do).name,
      :table
    ].freeze

    # === Parameters
    # block::
    #   A {Notion::Messages::Message}[https://github.com/orbit-love/notion-ruby-client/blob/main/lib/notion/messages/message.rb] object.
    #
    # === Returns
    # A boolean indicating if the blocked passed in
    # is permitted to have children based on its type.
    #
    def self.permitted_children?(block:)
      PERMITTED_CHILDREN.include?(block.type.to_sym) && block.has_children
    end

    # === Parameters
    # block_id::
    #   A string representing a notion block id .
    #
    # === Returns
    # An array of NotionToMd::Blocks::Block.
    #
    def self.build(block_id:, &fetch_blocks)
      blocks = fetch_blocks.call(block_id)
      blocks.results.map do |block|
        children = if permitted_children?(block: block)
                     build(block_id: block.id, &fetch_blocks)
                   else
                     []
                   end
        Factory.build(block: block, children: children)
      end
    end
  end
end
