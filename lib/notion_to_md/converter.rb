# frozen_string_literal: true

class NotionToMd
  # The Converter class allows to transform notion pages to markdown documents.
  # Just create a new Converter instance by providing the page_id:
  #   page_converter = NotionToMd::Converter.new(page_id: '9dc17c9c9d2e469dbbf0f9648f3288d3')
  # Then, call for convert to obtain the markdown document:
  #   page_converter.convert
  class Converter
    include Callee

    attr_reader :page_id, :frontmatter

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
      @notion = Notion::Client.new(token: token || ENV['NOTION_TOKEN'])
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
    def convert(frontmatter: false)
      md_page = Page.new(page: page, blocks: page_blocks)
      <<~MD
        #{md_page.frontmatter if frontmatter}
        #{md_page.body}
      MD
    end

    def call
      md = convert frontmatter: frontmatter

      yield md if block_given?

      md
    end

    private

    def page
      @page ||= @notion.page(page_id: page_id)
    end

    def page_blocks
      @page_blocks ||= build_blocks(block_id: page_id)
    end

    def build_blocks(block_id:)
      Blocks.build(block_id: block_id) do |nested_block_id|
        fetch_blocks(block_id: nested_block_id)
      end
    end

    def fetch_blocks(block_id:)
      @notion.block_children(block_id: block_id)
    end
  end
end
