# frozen_string_literal: true

module NotionToMd
  class Property
    class << self
      def file(prop)
        prop.dig(:file, :url)
      end

      def external(prop)
        prop.dig(:external, :url)
      end

      def emoji(prop)
        prop[:emoji]
      end

      def multi_select(prop)
        prop[:multi_select].map { |sel| sel[:name] }
      rescue NoMethodError
        nil
      end

      def select(prop)
        prop.dig(:select, :name)
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
      end

      def number(prop)
        prop[:number]
      end

      def email(prop)
        prop[:email]
      end

      def checkbox(prop)
        prop[:checkbox].nil? ? nil : prop[:checkbox].to_s
      end

      # date type properties not supported:
      # - end
      # - time_zone
      def date(prop)
        prop.date.start
      end

      def url(prop)
        prop.url
      end

      def rich_text(prop)
        prop.rich_text.map(&:plain_text).join
      end
    end
  end
end
