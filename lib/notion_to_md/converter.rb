# frozen_string_literal: true

require 'notion'
require_relative './logger'
require_relative './text_annotation'

module NotionToMd
  class Converter
    attr_reader :page_id

    def initialize(page_id:, token: nil)
      @notion = Notion::Client.new(token: token || ENV['NOTION_TOKEN'])
      @page_id = page_id
    end

    def convert
      md = page_blocks[:results].map do |block|
        next blank if block[:type] == 'paragraph' && block.dig(:paragraph, :text).empty?

        block_type = block[:type].to_sym
        begin
          send(block_type, block[block_type])
        rescue
          Logger.info("Unsupported block type: #{block_type}")
        end
      end
      Logger.info("Notion page #{page_id} converted to markdown")
      md.join("\n\n")
    end

    private

    def page_blocks
      @page_blocks ||= @notion.block_children(id: page_id)
    end


    def paragraph(block)
      convert_text(block)
    end

    def heading_1(block)
      "# #{convert_text(block)}"
    end

    def heading_2(block)
      "## #{convert_text(block)}"
    end

    def heading_3(block)
      "### #{convert_text(block)}"
    end

    def callout(block)
      icon = get_icon(block[:icon])
      text = convert_text(block)
      "#{icon} #{text}"
    end

    def quote(block)
      "> #{convert_text(block)}"
    end

    def bulleted_list_item(block)
      "- #{convert_text(block)}"
    end

    # TODO: numbered_list_item
    def numbered_list_item(block)
      Logger.info('numbered_list_item type not supported. Shown as bulleted_list_item.')
      bulleted_list_item(block)
    end

    def to_do(block)
      checked = block[:checked]
      text = convert_text(block)

      "- #{checked ? '[x]' : '[ ]'} #{text}"
    end

    def code(block)
      language = block[:language]
      text = convert_text(block)

      "```#{language}\n\t#{text}\n```"
    end

    def embed(block)
      url = block[:url]

      "[#{url}](#{url})"
    end

    def image(block)
      type = block[:type].to_sym
      url = block.dig(type, :url)
      caption = convert_caption(block)

      "![](#{url})\n\n#{caption}"
    end

    def bookmark(block)
      url = block[:url]
      "[#{url}](#{url})"
    end

    def divider(_block)
      '---'
    end

    def equation(block)
      equ = convert_text(block)
      "$$ #{equ} $$"
    end

    def blank
      '<br />'
    end

    def convert_text(block)
      block[:text].map do |text|
        content = text[:plain_text]
        enrich_text_content(text, content)
      end.join
    end

    def convert_caption(block)
      convert_text(text: block[:caption])
    end

    def get_icon(block)
      type = block[:type].to_sym
      block[type]
    end

    def enrich_text_content(text, content)
      enriched_content = add_link(text, content)
      add_annotations(text, enriched_content)
    end

    def add_link(text, content)
      href = text[:href]
      return content if href.nil?

      "[#{content}](#{href})"
    end

    def add_annotations(text, content)
      annotations = text[:annotations].select { |key, value| !!value }
      annotations.keys.inject(content) do |enriched_content, annotation|
        TextAnnotation.send(annotation.to_sym, enriched_content)
      end
    end
  end
end
