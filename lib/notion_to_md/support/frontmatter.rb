# frozen_string_literal: true

class NotionToMd
  module Support
    module Frontmatter
      include YamlSanitizer

      def frontmatter
        @frontmatter ||= <<~CONTENT
          ---
          #{frontmatter_properties.to_a.map do |k, v|
              "#{k}: #{v}"
            end.join("\n")}
          ---
        CONTENT
      end

      private

      def frontmatter_properties
        @frontmatter_properties ||= frontmatter_custom_properties.deep_merge(frontmatter_default_properties)
      end

      def frontmatter_custom_properties
        @frontmatter_custom_properties ||= compact_frontmatter_custom_properties
      end

      # rubocop:disable Metrics/MethodLength
      def frontmatter_default_properties
        @frontmatter_default_properties ||= {
          'id' => id,
          'title' => escape_frontmatter_value(title),
          'created_time' => created_time,
          'cover' => cover,
          'icon' => icon,
          'last_edited_time' => last_edited_time,
          'archived' => archived,
          'created_by_object' => created_by_object,
          'created_by_id' => created_by_id,
          'last_edited_by_object' => last_edited_by_object,
          'last_edited_by_id' => last_edited_by_id
        }
      end
      # rubocop:enable Metrics/MethodLength

      def compact_frontmatter_custom_properties
        build_frontmatter_custom_properties.reject { |_k, v| v.presence.nil? }
      end

      def build_frontmatter_custom_properties
        properties.each_with_object({}) do |(name, value), memo|
          type = value.type
          next unless valid_custom_property_type?(type)

          key = name.parameterize.underscore
          memo[key] = build_custom_property(type, value)
        end
      end

      def valid_custom_property_type?(type)
        MetadataType.respond_to?(type.to_sym)
      end

      def build_custom_property(type, value)
        MetadataType.send(type, value)
      end
    end
  end
end

