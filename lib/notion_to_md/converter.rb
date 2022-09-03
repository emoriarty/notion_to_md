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
      @page ||= @notion.page(page_id: page_id)
    end

    def page_blocks
      @page_blocks ||= build_blocks(block_id: page_id)
    end

    def build_blocks(block_id:)
      blocks = fetch_blocks(block_id: block_id)

      blocks.results.each do |block|
        block.children = if permitted_children?(block: block)
                           build_blocks(block_id: block.id)
                         else
                           []
                         end
      end

      blocks
    end

    def fetch_blocks(block_id:)
      @notion.block_children(block_id: block_id)
    end

    def permitted_children?(block:)
      block.has_children && Block::PERMITTED_CHILDREN.include?(block.type.to_sym)
    end
  end
end
