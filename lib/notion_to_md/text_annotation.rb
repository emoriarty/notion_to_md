# frozen_string_literal: true

module NotionToMd
  # Append the text type:
  # * italic: boolean,
  # * bold: boolean,
  # * striketrough: boolean,
  # * underline: boolean,
  # * code: boolean,
  # * color: string NOT_SUPPORTED
  class TextAnnotation
    class << self
      def italic(text)
        "*#{text}*"
      end

      def bold(text)
        "**#{text}**"
      end

      def striketrough(text)
        "~~#{text}~~"
      end

      def underline(text)
        text
      end

      def code(text)
        "`#{text}`"
      end

      def color(text)
        text
      end
    end
  end
end
