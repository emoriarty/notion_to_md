# frozen_string_literal: true

module NotionToMd
  class PageProperty
    class << self
      include Helpers::YamlSanitizer

      def file(prop)
        prop.dig(:file, :url)
      rescue NoMethodError
        nil
      end

      def external(prop)
        prop.dig(:external, :url)
      rescue NoMethodError
        nil
      end

      def emoji(prop)
        prop[:emoji]
      rescue NoMethodError
        nil
      end

      def multi_select(prop)
        prop[:multi_select].map { |sel| sel[:name] }
      rescue NoMethodError
        nil
      end

      def select(prop)
        escape_frontmatter_value(prop.dig(:select, :name))
      rescue NoMethodError
        nil
      end

      def people(prop)
        prop[:people].map { |sel| sel[:name] }
      rescue NoMethodError
        nil
      end

      def files(prop)
        prop[:files].map { |f| file(f) || external(f) }
      rescue NoMethodError
        nil
      end

      def phone_number(prop)
        prop[:phone_number]
      rescue NoMethodError
        nil
      end

      def number(prop)
        prop[:number]
      rescue NoMethodError
        nil
      end

      def email(prop)
        prop[:email]
      rescue NoMethodError
        nil
      end

      def checkbox(prop)
        prop[:checkbox].nil? ? nil : prop[:checkbox].to_s
      rescue NoMethodError
        nil
      end

      # date type properties not supported:
      # - end
      # - time_zone
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

      def url(prop)
        prop[:url]
      rescue NoMethodError
        nil
      end

      def rich_text(prop)
        text = prop[:rich_text].map { |text| text[:plain_text] }.join
        text.blank? ? nil : escape_frontmatter_value(text)
      rescue NoMethodError
        nil
      end
    end
  end
end
