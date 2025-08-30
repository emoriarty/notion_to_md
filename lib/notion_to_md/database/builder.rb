# frozen_string_literal: true

class NotionToMd
  class Database
    # === NotionToMd::Database::Builder
    #
    # Responsible for fetching and building all pages of a Notion database
    # into {NotionToMd::Page} instances. Handles pagination via `has_more`
    # and `next_cursor` automatically.
    #
    # @example Build pages for a database
    #   notion_client = Notion::Client.new(token: ENV["NOTION_TOKEN"])
    #   pages = NotionToMd::Database::Builder.call(
    #     database_id: "xxxx-xxxx",
    #     notion_client: notion_client,
    #     filter: { property: "Year", number: { equals: 2023 } },
    #     sorts: [{ property: "Title", direction: "ascending" }],
    #     frontmatter: true
    #   )
    #
    #   pages.each { |page| puts page.to_s }
    #
    # @see NotionToMd::Database
    # @see NotionToMd::Page
    class Builder
      include Support::Pagination

      class << self
        # Build pages from a database.
        #
        # @param database_id [String] The Notion database ID.
        # @param notion_client [Notion::Client] The Notion API client.
        # @param filter [Hash, nil] Optional filter to pass to the Notion API.
        # @param sorts [Array<Hash>, nil] Optional sort criteria.
        # @param frontmatter [Boolean] Whether to include frontmatter in page Markdown output.
        #
        # @return [Array<NotionToMd::Page>] An array of page objects.
        def call(database_id:, notion_client:, filter: nil, sorts: nil, frontmatter: false)
          new(
            database_id: database_id,
            notion_client: notion_client,
            filter: filter,
            sorts: sorts,
            frontmatter: frontmatter
          ).call
        end

        # @!method build(...)
        #   Alias of {.call}.
        alias build call
      end

      # @return [String] The database ID.
      attr_reader :database_id

      # @return [Notion::Client] The Notion API client.
      attr_reader :notion_client

      # @return [Hash, nil] Filter criteria passed to Notion API.
      attr_reader :filter

      # @return [Array<Hash>, nil] Sort criteria passed to Notion API.
      attr_reader :sorts

      # @return [Hash] Options for building pages (e.g. `{ frontmatter: true }`).
      attr_reader :page_options

      # Initialize a new builder.
      #
      # @param database_id [String] The Notion database ID.
      # @param notion_client [Notion::Client] The Notion API client.
      # @param filter [Hash, nil] Optional filter to pass to the Notion API.
      # @param sorts [Array<Hash>, nil] Optional sort criteria.
      # @param frontmatter [Boolean] Whether to include frontmatter in page Markdown output.
      def initialize(database_id:, notion_client:, filter: nil, sorts: nil, frontmatter: false)
        @database_id = database_id
        @notion_client = notion_client
        @filter = filter
        @sorts = sorts
        @page_options = { frontmatter: frontmatter }
      end

      # Fetch and build all pages of the database.
      #
      # @return [Array<NotionToMd::Page>]
      def call
        fetch_pages.map do |page|
          NotionToMd::Page.call(id: page.id, notion_client: notion_client, **page_options)
        end
      end

      # Fetch all raw page records from the Notion database.
      #
      # @return [Array<Notion::Messages::Message>] Raw page messages from the Notion API.
      def fetch_pages
        params = {}

        paginate do |cursor|
          params = { database_id: database_id, filter: filter, sorts: sorts }.compact
          params[:start_cursor] = cursor if cursor

          notion_client.database_query(params)
        end
      end
    end
  end
end
