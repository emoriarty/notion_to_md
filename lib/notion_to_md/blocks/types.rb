# frozen_string_literal: true

module NotionToMd
  module Blocks
    class Types
      class << self
        def paragraph(block)
          return blank if block.rich_text.empty?

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
          "> #{icon} #{text}"
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

        def video(block)
          url = block.dig(:file, :url) || block.dig(:external, :url)

          "![](#{url})\n\n#"
        end

        def file(block)
          type = block[:type]
          url = block.dig(type, :url) || block.dig(:external, :url)

          "![](#{url})\n\n#"
        end

        def pdf(block)
          url = block.dig(:file, :url) || block.dig(:external, :url)

          "![](#{url})\n\n#"
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

        def table_row(block)
          "|#{block[:cells].map(&method(:convert_table_row)).join('|')}|"
        end

        def toggle(block)
          result = <<-TEXT
            <details>
              <summary>#{block.block.toggle["rich_text"].map { |text| Text.send(text[:type], text) }.join}</summary>
              #{block.children.map(&:to_md).join}
            </details>
          TEXT
          result.join("\n")
        end

        def equation(block)
          result = []
          result << "> [!CAUTION]"
          result << "> **Unsupported Equation Block**"
          result << "> <br />"
          result << "> Content needs to be imported manually."
          result << "> <br />"
          result << "> <br />"
          result << "> This is the equation to help you find it in the original Notion page:"
          result << "> <br />"
          result << "> **#{block[:expression]}**" # Returns ruby code with the equation at least
          result << "> <br />"
          result.join("\n")
        end

        def column_list(block)
          result = []
          result << "> [!CAUTION]"
          result << "> **Unsupported Column List Block**"
          result << "> <br />"
          result << "> Content needs to be imported manually."
          result << "> <br />"
          result << "> <br />"
          result << "> This exercise contains a column list. The content of each column needs to be imported manually. Unfortunately, Notion does not provide a way to access the content of each column."
          result << "> <br />"
          result.join("\n")
        end

        def child_database(block)
          result = []
          result << "> [!CAUTION]"
          result << "> **Unsupported Child Database Block**"
          result << "> <br />"
          result << "> Content needs to be imported manually."
          result << "> <br />"
          result << "> <br />"
          result << "> This is the child database title to help you find it in the original Notion page:"
          result << "> <br />"
          result << "> **#{block[:title]}**"
          result << "> <br />"
          result.join("\n")
        end

        def child_page(block)
          result = []
          result << "> [!CAUTION]"
          result << "> **Unsupported Child Page Block**"
          result << "> <br />"
          result << "> Content needs to be imported manually."
          result << "> <br />"
          result << "> <br />"
          result << "> This is the child page title to help you find it in the original Notion page:"
          result << "> <br />"
          result << "> **#{block[:title]}**"
          result << "> <br />"
          result.join("\n")
        end

        def link_to_page(block)
          result = []
          result << "> [!CAUTION]"
          result << "> **Unsupported Link to Page Block**"
          result << "> <br />"
          result << "> Content needs to be imported manually."
          result << "> <br />"
          result << "> <br />"
          result << "> This is the link_id to page title to help you find it in the original Notion page:"
          result << "> <br />"
          result << "> **#{block[:page_id]}**"
          result << "> <br />"
          result.join("\n")
        end

        def synced_block(block)
          result = []
          result << "> [!CAUTION]"
          result << "> **Unsupported Synced Block**"
          result << "> <br />"
          result << "> Content needs to be imported manually."
          result << "> <br />"
          result << "> <br />"
          result << "> This is the synced block title to help you find it in the original Notion page:"
          result << "> <br />"
          if block[:synced_from]
            result <<"> **#{block[:synced_from][:block_id]}**"
          else
            "> **Synced block has no synced_from attribute.**"
          end
          result << "> <br />"
          result.join("\n")
        end

        private

        def convert_table_row(cells)
          cells.map(&method(:convert_table_cell))
        end

        def convert_table_cell(text)
          convert_text({ rich_text: [text] })
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
end
