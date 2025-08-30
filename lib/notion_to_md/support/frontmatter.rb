# frozen_string_literal: true

class NotionToMd
  module Support
    # === NotionToMd::Support::Frontmatter
    #
    # Mixin module responsible for generating YAML frontmatter for
    # Notion pages and databases. Combines default metadata (id, title,
    # timestamps, cover, icon, etc.) with supported custom properties.
    #
    # @example Use in a page class
    #   class Page
    #     include NotionToMd::Support::MetadataProperties
    #     include NotionToMd::Support::Frontmatter
    #     attr_reader :metadata
    #   end
    #
    #   page = Page.new(metadata: notion_page_hash)
    #   puts page.frontmatter
    #   # =>
    #   # ---
    #   # id: 1234
    #   # title: "Hello World"
    #   # created_time: 2025-01-01 00:00:00 +0000
    #   # ...
    #   # ---
    #
    # @see NotionToMd::Support::YamlSanitizer
    # @see NotionToMd::MetadataType
    module Frontmatter
      include YamlSanitizer

      # Generate the YAML frontmatter string by merging default and custom properties.
      #
      # @return [String] YAML frontmatter block, surrounded by `---` markers.
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

      # Merge custom and default properties into the final set of frontmatter properties.
      #
      # @return [Hash{String => Object}]
      def frontmatter_properties
        @frontmatter_properties ||= frontmatter_custom_properties.deep_merge(frontmatter_default_properties)
      end

      # Retrieve sanitized custom properties.
      #
      # @return [Hash{String => Object}]
      def frontmatter_custom_properties
        @frontmatter_custom_properties ||= compact_frontmatter_custom_properties
      end

      # Remove nil/blank values from custom properties.
      #
      # @return [Hash{String => Object}]
      def compact_frontmatter_custom_properties
        build_frontmatter_custom_properties.reject { |_k, v| v.presence.nil? }
      end

      # Build supported custom properties based on their type.
      #
      # @return [Hash{String => Object}]
      def build_frontmatter_custom_properties
        properties.each_with_object({}) do |(name, value), memo|
          type = value.type
          next unless valid_custom_property_type?(type)

          key = name.parameterize.underscore
          memo[key] = build_custom_property(type, value)
        end
      end

      # Determine whether a custom property type is supported.
      #
      # @param type [String, Symbol]
      # @return [Boolean]
      def valid_custom_property_type?(type)
        MetadataType.respond_to?(type.to_sym)
      end

      # Convert a Notion property into a YAML-safe value.
      #
      # @param type [String, Symbol] The property type.
      # @param value [Object] The raw Notion property value.
      # @return [Object] The normalized value suitable for YAML.
      def build_custom_property(type, value)
        MetadataType.send(type, value)
      end

      # Default frontmatter properties derived from metadata.
      #
      # @return [Hash{String => Object}]
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
    end
  end
end
