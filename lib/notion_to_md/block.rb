# frozen_string_literal: true

require 'forwardable'

module NotionToMd
  class Block
    extend Forwardable

    PERMITTED_CHILDREN = %i[bulleted_list_item numbered_list_item].freeze
    TAB = "\t"

    attr_reader :block

    def_delegators :block, :has_children, :children

    def initialize(block:)
      @block = block
    end

    def children?
      has_children
    end

    def to_md(current_block: block, tab_width: 0)
      block_type = current_block.type.to_sym
      md = Block.send(block_type, current_block[block_type])
      md += build_children(tab_width: tab_width + 1) if children?
      md
    rescue StandardError => e
      Logger.info("Unsupported block type: #{block_type}")
      nil
    end

    private

    def build_children(tab_width:)
      nested_mds = children.map do |nested_block|
        nested_block.to_md(tab_width: tab_width)
      end.compact
      nested_mds.map do |nested_md|
        "\n#{TAB * tab_width}#{nested_md}"
      end.join
    end

    class << self
      def paragraph(block)
        return Block.blank if block.rich_text.empty?

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

        language = 'text' if language == 'plain text'

        "```#{language}\n#{text}\n```"
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

      def blank
        '<br />'
      end

      def convert_text(block)
        block[:rich_text].map do |text|
          content = Text.send(text[:type], text)
          enrich_text_content(text, content)
        end.join
      end

      def convert_caption(block)
        convert_text(rich_text: block[:caption])
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
        annotations = text[:annotations].select { |_key, value| !!value }
        annotations.keys.inject(content) do |enriched_content, annotation|
          TextAnnotation.send(annotation.to_sym, enriched_content)
        end
      end
    end
  end
end
