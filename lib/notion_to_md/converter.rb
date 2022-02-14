# frozen_string_literal: true

module NotionToMd
  class Converter
    attr_reader :page_id

    def initialize(page_id:, token: nil)
      @notion = Notion::Client.new(token: token || ENV['NOTION_TOKEN'])
      @page_id = page_id
    end

    def convert(frontmatter: false)
      <<~MD
        #{parse_frontmatter if frontmatter}
        #{parse_content}
      MD
    end

    private

    def parse_content
      md = page_blocks[:results].map do |block|
        next Block.blank if block[:type] == 'paragraph' && block.dig(:paragraph, :text).empty?

        block_type = block[:type].to_sym

        begin
          Block.send(block_type, block[block_type])
        rescue StandardError
          Logger.info("Unsupported block type: #{block_type}")
          next nil
        end
      end
      Logger.info("Notion page #{page_id} converted to markdown")
      md.compact.join("\n\n")
    end

    def parse_frontmatter
      notion_page = Page.new(page: page)
      frontmatter = notion_page.props.to_a.map { |k, v| "#{k}: #{v}" }.join("\n")
      <<~CONTENT
        ---
        #{frontmatter}
        ---
      CONTENT
    end

    def page
      @page ||= @notion.page(id: page_id)
    end

    def page_blocks
      @page_blocks ||= @notion.block_children(id: page_id)
    end
  end
end
