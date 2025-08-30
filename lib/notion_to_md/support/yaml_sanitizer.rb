# frozen_string_literal: true

class NotionToMd
  module Support
    module YamlSanitizer
      # Escape the frontmatter value if it contains a colon or a dash followed by a space
      # @param value [String] the value to escape
      # @return [String] the escaped value
      def escape_frontmatter_value(value)
        if value.match?(/: |-\s/)
          # Escape the double quotes inside the string
          "\"#{value.gsub('"', '\"')}\""
        else
          value
        end
      end
    end
  end
end
