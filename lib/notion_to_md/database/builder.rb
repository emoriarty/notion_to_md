# frozen_string_literal: true

class NotionToMd
  class Database
    class Builder
      class << self
        def call(database_id:, notion_client:, filter: nil, sorts: nil, frontmatter: false)
          new(database_id: database_id, notion_client: notion_client, filter: filter, sorts: sorts, frontmatter: frontmatter).call
        end

        alias build call
      end

      attr_reader :database_id, :notion_client, :filter, :sorts, :page_options

      def initialize(database_id:, notion_client:, filter: nil, sorts: nil, frontmatter: false)
        @database_id = database_id
        @notion_client = notion_client
        @filter = filter
        @sorts = sorts
        @page_options = { frontmatter: frontmatter }
      end

      def call
        fetch_pages.map do |page|
          NotionToMd::Page.call(id: page.id, notion_client: notion_client, **page_options)
        end
      end

      def fetch_pages
        all_pages = []
        start_cursor = nil

        loop do
          params = { database_id: database_id, filter: filter, sorts: sorts }.compact
          params[:start_cursor] = start_cursor if start_cursor

          resp = notion_client.database_query(params)

          all_pages.concat(resp.results)

          break unless resp.has_more && resp.next_cursor

          start_cursor = resp.next_cursor
        end

        all_pages
      end
    end
  end
end
