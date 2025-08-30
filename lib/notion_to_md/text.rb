# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Text
  #
  # Utility class to render inline Notion text elements into Markdown.
  # Used by {NotionToMd::Blocks::Renderer} when processing `rich_text` arrays.
  #
  # Supported types:
  # * `text` → plain text
  # * `equation` → LaTeX inline math, wrapped as `$`…`$`
  #
  # @example Render plain text
  #   NotionToMd::Text.text({ plain_text: "Hello" })
  #   # => "Hello"
  #
  # @example Render an inline equation
  #   NotionToMd::Text.equation({ plain_text: "E=mc^2" })
  #   # => "$`E=mc^2`$"
  #
  # @see NotionToMd::Blocks::Renderer
  # @see NotionToMd::TextAnnotation
  class Text
    class << self
      # Render a plain text element.
      #
      # @param text [Hash] A Notion text object with key `:plain_text`.
      # @return [String] The raw text.
      def text(text)
        text[:plain_text]
      end

      # Render an inline equation element.
      #
      # @param text [Hash] A Notion text object with key `:plain_text`.
      # @return [String] Inline math expression wrapped with `$...$`.
      def equation(text)
        "$`#{text[:plain_text]}`$"
      end
    end
  end
end
