# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::TextAnnotation
  #
  # Utility class to wrap text with Markdown (or HTML) syntax
  # corresponding to Notion's text annotations.
  #
  # Supported annotations:
  # * `italic` → `*text*`
  # * `bold` → `**text**`
  # * `strikethrough` → `~~text~~`
  # * `underline` → `<u>text</u>` (HTML, since Markdown does not support underline)
  # * `code` → `` `text` ``
  # * `color` → (not supported, returns text as-is)
  #
  # @example Apply bold and italic
  #   NotionToMd::TextAnnotation.bold("Hello")          # => "**Hello**"
  #   NotionToMd::TextAnnotation.italic("World")        # => "*World*"
  #
  # @example Apply underline
  #   NotionToMd::TextAnnotation.underline("Note")      # => "<u>Note</u>"
  #
  # @see NotionToMd::Blocks::Renderer
  class TextAnnotation
    class << self
      # Apply italic annotation.
      # @param text [String]
      # @return [String]
      def italic(text)
        "*#{text}*"
      end

      # Apply bold annotation.
      # @param text [String]
      # @return [String]
      def bold(text)
        "**#{text}**"
      end

      # Apply strikethrough annotation.
      # @param text [String]
      # @return [String]
      def strikethrough(text)
        "~~#{text}~~"
      end

      # Apply underline annotation (HTML).
      # @param text [String]
      # @return [String]
      def underline(text)
        "<u>#{text}</u>"
      end

      # Apply inline code annotation.
      # @param text [String]
      # @return [String]
      def code(text)
        "`#{text}`"
      end

      # Color annotation is not supported in Markdown.
      # Currently returns text unchanged.
      #
      # @param text [String]
      # @return [String]
      def color(text)
        text
      end
    end
  end
end
