# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::MetadataType
  #
  # Utility class responsible for extracting and sanitizing values
  # from Notion database/page property objects. Each class method
  # corresponds to a Notion property type and returns a normalized
  # Ruby value suitable for use in YAML frontmatter or Markdown.
  #
  # This class is typically used indirectly via
  # {NotionToMd::Support::MetadataProperties}.
  #
  # @example Extract a multi-select property
  #   prop = { multi_select: [{ name: "Action" }, { name: "Drama" }] }
  #   NotionToMd::MetadataType.multi_select(prop)
  #   # => ["Action", "Drama"]
  #
  # @example Extract a date property
  #   prop = { date: { start: "2024-01-01T00:00:00Z" } }
  #   NotionToMd::MetadataType.date(prop)
  #   # => 2024-01-01 00:00:00 +0000
  #
  # @see NotionToMd::Support::YamlSanitizer
  class MetadataType
    class << self
      include Support::YamlSanitizer

      # Extract file URL.
      # @param prop [Hash]
      # @return [String, nil]
      def file(prop)
        prop.dig(:file, :url)
      rescue NoMethodError
        nil
      end

      # Extract external file URL.
      # @param prop [Hash]
      # @return [String, nil]
      def external(prop)
        prop.dig(:external, :url)
      rescue NoMethodError
        nil
      end

      # Extract emoji character.
      # @param prop [Hash]
      # @return [String, nil]
      def emoji(prop)
        prop[:emoji]
      rescue NoMethodError
        nil
      end

      # Extract multi-select values as names.
      # @param prop [Hash]
      # @return [Array<String>, nil]
      def multi_select(prop)
        prop[:multi_select].map { |sel| sel[:name] }
      rescue NoMethodError
        nil
      end

      # Extract selected option name.
      # Escapes YAML-sensitive characters.
      # @param prop [Hash]
      # @return [String, nil]
      def select(prop)
        escape_frontmatter_value(prop.dig(:select, :name))
      rescue NoMethodError
        nil
      end

      # Extract people names.
      # @param prop [Hash]
      # @return [Array<String>, nil]
      def people(prop)
        prop[:people].map { |sel| sel[:name] }
      rescue NoMethodError
        nil
      end

      # Extract file or external URLs from files list.
      # @param prop [Hash]
      # @return [Array<String>, nil]
      def files(prop)
        prop[:files].map { |f| file(f) || external(f) }
      rescue NoMethodError
        nil
      end

      # Extract phone number.
      # @param prop [Hash]
      # @return [String, nil]
      def phone_number(prop)
        prop[:phone_number]
      rescue NoMethodError
        nil
      end

      # Extract number.
      # @param prop [Hash]
      # @return [Numeric, nil]
      def number(prop)
        prop[:number]
      rescue NoMethodError
        nil
      end

      # Extract email.
      # @param prop [Hash]
      # @return [String, nil]
      def email(prop)
        prop[:email]
      rescue NoMethodError
        nil
      end

      # Extract checkbox (as string "true"/"false").
      # @param prop [Hash]
      # @return [String, nil]
      def checkbox(prop)
        prop[:checkbox]&.to_s
      rescue NoMethodError
        nil
      end

      # Extract date value.
      # Converts strings to {Time}, {Date} to {Time}, leaves Time unchanged.
      # End date and time zone are not supported.
      #
      # @param prop [Hash]
      # @return [Time, String, nil] Parsed start date, raw value, or nil.
      def date(prop)
        date = prop.dig(:date, :start)

        case date
        when Date
          date.to_time
        when String
          Time.parse(date)
        else
          date # Time or nil
        end
      rescue NoMethodError
        nil
      end

      # Extract URL.
      # @param prop [Hash]
      # @return [String, nil]
      def url(prop)
        prop[:url]
      rescue NoMethodError
        nil
      end

      # Extract rich text as plain string, escaped for YAML if necessary.
      # @param prop [Hash]
      # @return [String, nil]
      def rich_text(prop)
        text = prop[:rich_text].map { |text| text[:plain_text] }.join
        text.blank? ? nil : escape_frontmatter_value(text)
      rescue NoMethodError
        nil
      end
    end
  end
end
