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
        metadata = notion_client.page(page_id: id)
        blocks = Builder.call(block_id: id, notion_client: notion_client)

        new(metadata: metadata, children: blocks, frontmatter: frontmatter)
      end

      # @!method build(...)
      #   Alias of {.call}.
      alias build call
    end

    # @return [Object] The metadata associated with the page.
    attr_reader :metadata

    # @return [Array<#to_md>] The list of child blocks belonging to the page.
    attr_reader :children

    # @!method blocks
    #   Alias for {#children}.
    alias blocks children

    # Initialize a new Page.
    #
    # @param metadata [Object] The Notion page metadata.
    # @param children [Array<#to_md>] The block children belonging to the page.
    # @param frontmatter [Boolean] Whether to include frontmatter in the Markdown output.
    def initialize(metadata:, children:, frontmatter: false)
      @metadata = metadata
      @children = children
      @config = { frontmatter: frontmatter }
    end

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
      @config[:frontmatter]
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
