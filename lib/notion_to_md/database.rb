# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Database
  #
  # Represents a Notion database and allows converting its pages
  # into Markdown documents.
  #
  # A `Database` object encapsulates the database metadata and
  # the collection of {NotionToMd::Page} children it contains.
  #
  # @example Convert a Notion database to Markdown
  #   notion_client = Notion::Client.new(token: ENV["NOTION_TOKEN"])
  #   db = NotionToMd::Database.call(id: "xxxx-xxxx", notion_client: notion_client, frontmatter: true)
  #
  #   db.to_s.each_with_index do |page_md, idx|
  #     File.write("page_#{idx}.md", page_md)
  #   end
  #
  # @see NotionToMd::Page
  # @see NotionToMd::Database::Builder
  class Database
    include Support::MetadataProperties

    class << self
      # Build a new {Database} from the Notion API.
      #
      # @param id [String] The Notion database ID.
      # @param notion_client [Notion::Client] The Notion API client.
      # @param filter [Hash, nil] Optional filter criteria to pass to the Notion API.
      # @param sorts [Array<Hash>, nil] Optional sort criteria.
      # @param frontmatter [Boolean] Whether to include frontmatter in each page’s Markdown output.
      #
      # @return [NotionToMd::Database] a new database instance.
      #
      # @see .build
      def call(id:, notion_client:, filter: nil, sorts: nil, frontmatter: false)
        metadata = notion_client.database(database_id: id)
        pages = Builder.call(
          database_id: id,
          notion_client: notion_client,
          filter: filter,
          sorts: sorts,
          frontmatter: frontmatter
        )

        new(metadata: metadata, children: pages)
      end

      # @!method build(...)
      #   Alias of {.call}.
      alias build call
    end

    # @return [Object] The metadata associated with the database.
    attr_reader :metadata

    # @return [Array<NotionToMd::Page>] The pages contained in the database.
    attr_reader :children

    # @!method pages
    #   Alias for {#children}.
    alias pages children

    # Initialize a new database representation.
    #
    # @param metadata [Object] The Notion database metadata.
    # @param children [Array<NotionToMd::Page>] The pages belonging to the database.
    def initialize(metadata:, children:)
      @metadata = metadata
      @children = children
    end

    # Convert all database pages into Markdown.
    #
    # @return [Array<String>] Markdown documents for each page in the database.
    def to_s
      pages.map(&:to_s)
    end

    # @!method to_md
    #   Alias for {#to_s}.
    alias to_md to_s
  end
end
