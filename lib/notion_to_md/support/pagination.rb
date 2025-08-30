# frozen_string_literal: true

class NotionToMd
  module Support
    ##
    # The Pagination module provides a helper for iterating through paginated
    # Notion API responses.
    #
    # Many Notion API endpoints (e.g., `block_children`, `database_query`) return
    # a limited set of results and include `has_more` and `next_cursor` fields.
    # This module encapsulates the common logic to repeatedly fetch all pages
    # until no more results are available.
    #
    # @example Paginate through all blocks of a page
    #   include NotionToMd::Support::Pagination
    #
    #   all_blocks = paginate do |cursor|
    #     notion_client.block_children(
    #       block_id: "xxxx-xxxx",
    #       start_cursor: cursor
    #     )
    #   end
    #
    #   all_blocks.each { |block| puts block.type }
    #
    module Pagination
      ##
      # Iterates through all pages of a paginated Notion API response.
      #
      # The given block is called with the current cursor (or `nil` for the
      # first call). It must return a response object that responds to
      # `results`, `has_more`, and `next_cursor`.
      #
      # @yieldparam [String, nil] cursor the current cursor to start fetching from
      # @yieldreturn [Object] a response object containing `results`, `has_more`, and `next_cursor`
      # @return [Array] a flat array of all accumulated results from each page
      def paginate
        results = []
        cursor  = nil

        loop do
          resp = yield(cursor)

          results.concat(resp.results)

          break unless resp.has_more && resp.next_cursor

          cursor = resp.next_cursor
        end

        results
      end
    end
  end
end
