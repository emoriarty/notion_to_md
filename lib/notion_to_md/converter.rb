# frozen_string_literal: true

class NotionToMd
  # The Converter class allows to transform notion pages to markdown documents.
  # Just create a new Converter instance by providing the page_id:
  #   page_converter = NotionToMd::Converter.new(page_id: '9dc17c9c9d2e469dbbf0f9648f3288d3')
  # Then, call for convert to obtain the markdown document:
  #   page_converter.call
  class Converter
    class << self
      def call(page_id:, token: nil, frontmatter: false)
        md = new(page_id: page_id, token: token, frontmatter: frontmatter).call

        yield md if block_given?

        md
      end

      alias convert call
    end

    attr_reader :page_id, :frontmatter, :notion_client

    # === Parameters
    # page_id::
    #   A string representing the notion page id.
    # token::
    #   The notion API secret token. The token can replaced by the environment variable NOTION_TOKEN.
    #
    # === Returns
    # A NotionToMd::Converter object.
    #
    def initialize(page_id:, token: nil, frontmatter: false)
      @notion_client = Notion::Client.new(token: token || ENV.fetch('NOTION_TOKEN', nil))
      @page_id = page_id
      @frontmatter = frontmatter
    end

    # === Parameters
    # frontmatter::
    #   A boolean value that indicates whether the front matter block is included in the markdown document.
    #
    # === Returns
    # The string that represent the markdown document.
    #
    def call
      md_page = Page.build(id: page_id, notion_client: notion_client)
      <<~MD
        #{md_page.frontmatter if frontmatter}
        #{md_page.body}
      MD
    end

    alias convert call
  end
end
