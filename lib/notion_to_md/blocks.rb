# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Blocks
  #
  # This module is responsible for building Notion blocks.
  module Blocks
    # === Parameters
    # block_id::
    #   A string representing a notion block id .
    # fetch_blocks::
    #   A block that fetches the blocks from the Notion API.
    #
    # === Returns
    # An array of NotionToMd::Blocks::Block.
    #
    def self.build(block_id:, &fetch_blocks)
      Builder.new(block_id: block_id, &fetch_blocks).build
    end
  end
end
