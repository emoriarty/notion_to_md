# frozen_string_literal: true

module NotionToMd
  ##
  # The Converter class allows to transform notion pages to markdown documents.
  # Just create a new Converter instance by providing the page_id:
  #   page_converter = NotionToMd::Converter.new(page_id: '9dc17c9c9d2e469dbbf0f9648f3288d3')
  # Then, call for convert to obtain the markdown document:
  #   page_converter.convert

  class Converter
    attr_reader :page_id

    # === Parameters
    # page_id::
    #   A string representing the notion page id.
    # token::
    #   The notion API secret token. The token can replaced by the environment variable NOTION_TOKEN.
    #
    # === Returns
    # A NotionToMd::Converter object.
    #
    def initialize(page_id:, token: nil)
      @notion = Notion::Client.new(token: token || ENV['NOTION_TOKEN'])
      @page_id = page_id
    end

    # === Parameters
    # frontmatter::
    #   A boolean value that indicates whether the front matter block is included in the markdown document.
    #
    # === Returns
    # The string that represent the markdown document.
    #
    def convert(frontmatter: false)
      md_page = Page.new(page: page, blocks: page_blocks)
      <<~MD
        #{md_page.frontmatter if frontmatter}
        #{md_page.body}
      MD
    end

    private

    def page
      @page ||= @notion.page(page_id: page_id)
    end

    def page_blocks
      @page_blocks ||= build_blocks(block_id: page_id)
    end

    def build_blocks(block_id:)
      blocks = fetch_blocks(block_id: block_id)
      Blocks.build(blocks: blocks)
    end

    def fetch_blocks(block_id:)
      @notion.block_children(block_id: block_id)
    end
  end
end
