# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Page
  #
  # Represents a Notion page and allows conversion to Markdown.
  #
  # A `Page` object encapsulates the page metadata, its content blocks,
  # and optionally the frontmatter section.
  #
  # @example Convert a Notion page to Markdown
  #   notion_client = Notion::Client.new(token: ENV["NOTION_TOKEN"])
  #   page = NotionToMd::Page.call(id: "xxxx-xxxx", notion_client: notion_client, frontmatter: true)
  #   File.write("page.md", page.to_s)
  #
  class Page
    include Support::MetadataProperties
    include Support::Frontmatter

    class << self
      # Build a new {Page} from the Notion API.
      #
      # @param id [String] The Notion page ID.
      # @param notion_client [Notion::Client] The Notion API client.
      # @param frontmatter [Boolean] Whether to include frontmatter in the output.
      #
      # @return [NotionToMd::Page] a new page instance.
      #
      # @see .build
      def call(id:, notion_client:, frontmatter: false)
        new(id: id, notion_client: notion_client, frontmatter: frontmatter).call
      end

      # @!method build(...)
      #   Alias of {.call}.
      alias build call
    end

    # @return [String] The Notion id page.
    attr_reader :id

    # @param jNotion::Client] The Notion API client.
    attr_reader :notion_client

    # @param [Hash] The page configuration options.
    attr_reader :config

    # @return [Object] The metadata associated with the page.
    attr_reader :metadata

    # @return [Array<#to_md>] The list of child blocks belonging to the page.
    attr_reader :children

    # @!method blocks
    #   Alias for {#children}.
    alias blocks children

    # Initialize a new Page.
    #
    # @param id [String] The Notion page ID.
    # @param notion_client [Notion::Client] The Notion API client.
    # @param frontmatter [Boolean] Whether to include frontmatter in the Markdown output.
    def initialize(id:, notion_client:, frontmatter: false)
      @id = id
      @notion_client = notion_client
      @config = { frontmatter: frontmatter }
    end

    # Fetch page data and child blocks from the Notion API.
    #
    # This method populates the page's metadata and children by making API calls
    # to retrieve the page content and its nested blocks.
    #
    # @return [NotionToMd::Page] returns self to allow method chaining.
    def call
      @metadata = notion_client.page(page_id: id)
      @children = Builder.call(block_id: id, notion_client: notion_client)
      self
    end

    alias build call

    # Render the body of the page (Markdown representation of its blocks).
    #
    # @return [String] The Markdown content of the page.
    def body
      @body ||= blocks.map(&:to_md).compact.join
    end

    # Whether the page includes frontmatter.
    #
    # @return [Boolean]
    def frontmatter?
      config[:frontmatter]
    end

    # Render the page as a Markdown string, including optional frontmatter.
    #
    # @return [String] The Markdown document.
    def to_s
      <<~MD
        #{frontmatter if frontmatter?}
        #{body}
      MD
    end

    # @!method to_md
    #   Alias for {#to_s}.
    alias to_md to_s
  end
end
