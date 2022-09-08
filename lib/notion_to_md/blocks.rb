# frozen_string_literal: true

require_relative './blocks/block'
require_relative './blocks/types'

module NotionToMd
  module Blocks
    ##
    # Array containing the block types allowed to have nested blocks (children).
    PERMITTED_CHILDREN = [
      Types.method(:bulleted_list_item).name,
      Types.method(:numbered_list_item).name
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
      block.has_children && PERMITTED_CHILDREN.include?(block.type.to_sym)
    end

    # === Parameters
    # blocks::
    #   An array of {Notion::Messages::Message}[https://github.com/orbit-love/notion-ruby-client/blob/main/lib/notion/messages/message.rb].
    #
    # === Returns
    # An array of NotionToMd::Blocks::Block.
    #
    def self.build(blocks:)
      blocks.results.map do |block|
        children = if permitted_children?(block: block)
                     build(block_id: block.id)
                   else
                     []
                   end
        Blocks::Block.new(block: block, children: children)
      end
    end
  end
end
