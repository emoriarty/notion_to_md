# frozen_string_literal: true

module NotionToMd
  class Converter
    attr_reader :page_id

    def initialize(page_id:, token: nil)
      @notion = Notion::Client.new(token: token || ENV['NOTION_TOKEN'])
      @page_id = page_id
    end

    def convert(frontmatter: false)
      md_page = Page.new(page: page, blocks: page_blocks)
      <<~MD
        #{md_page.frontmatter if frontmatter}
        #{md_page.body}
      MD
    end

    private

    def page
      @page ||= @notion.page(id: page_id)
    end

    def page_blocks
      @page_blocks ||= @notion.block_children(id: page_id)
    end
  end
end
