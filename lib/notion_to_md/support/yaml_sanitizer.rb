# frozen_string_literal: true

class NotionToMd
  module Support
    # === NotionToMd::Support::YamlSanitizer
    #
    # Provides helpers to sanitize values before inserting them into
    # YAML frontmatter. This prevents syntax errors when values contain
    # characters that YAML treats specially (e.g. colons, dashes).
    #
    # @example Escape a simple value
    #   include NotionToMd::Support::YamlSanitizer
    #
    #   escape_frontmatter_value("Hello World")
    #   # => "Hello World"
    #
    # @example Escape a value containing a colon
    #   escape_frontmatter_value("Title: Subtitle")
    #   # => "\"Title: Subtitle\""
    #
    # @example Escape a value containing dash + space
    #   escape_frontmatter_value("- item")
    #   # => "\"- item\""
    #
    module YamlSanitizer
      # Escape a frontmatter value if it contains a colon (`:`) followed by
      # a space, or a dash followed by a space (`- `). Wraps the string in
      # double quotes and escapes any embedded quotes.
      #
      # @param value [String] The raw value to escape.
      # @return [String] A safe string suitable for inclusion in YAML frontmatter.
      def escape_frontmatter_value(value)
        if value.match?(/: |-\s/)
          # Escape embedded double quotes to keep valid YAML
          "\"#{value.gsub('"', '\"')}\""
        else
          value
        end
      end
    end
  end
end
