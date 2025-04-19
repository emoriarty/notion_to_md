# frozen_string_literal: true

require_relative './blocks/builder'
require_relative './blocks/normalizer'
require_relative './blocks/factory'
require_relative './blocks/types'
require_relative './blocks/block'
require_relative './blocks/table_block'
require_relative './blocks/table_row_block'
require_relative './blocks/bulleted_list_block'
require_relative './blocks/bulleted_list_item_block'
require_relative './blocks/numbered_list_block'
require_relative './blocks/numbered_list_item_block'
require_relative './blocks/to_do_list_block'
require_relative './blocks/to_do_list_item_block'

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
