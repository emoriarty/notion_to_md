# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Page
  #
  # This class is responsible for representing a Notion page.
  class Page
    include Helpers::YamlSanitizer
    include Support::MetadataProperties

    class << self
      def call(id:, notion_client:)
        metadata = notion_client.page(page_id: id)
        blocks = Blocks::Builder.call(block_id: id, notion_client: notion_client)

        new(metadata: metadata, children: blocks)
      end

      alias build call
    end

    attr_reader :metadata, :children

    alias blocks children

    def initialize(metadata:, children:)
      @metadata = metadata
      @children = children
    end

    def body
      @body ||= blocks.map(&:to_md).compact.join
    end

    def frontmatter
      @frontmatter ||= <<~CONTENT
        ---
        #{props.to_a.map do |k, v|
            "#{k}: #{v}"
          end.join("\n")}
        ---
      CONTENT
    end

    def props
      @props ||= custom_props.deep_merge(default_props)
    end

    def custom_props
      @custom_props ||= filtered_custom_properties
    end

    # rubocop:disable Metrics/MethodLength
    def default_props
      @default_props ||= {
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

    # This class is kept for retro compatibility reasons.
    # Use instead the MetadataType class.
    class CustomProperty < MetadataType
    end

    private

    def filtered_custom_properties
      build_custom_properties.reject { |_k, v| v.presence.nil? }
    end

    def build_custom_properties
      properties.each_with_object({}) do |(name, value), memo|
        type = value.type
        next unless valid_custom_property_type?(type)

        key = name.parameterize.underscore
        memo[key] = build_custom_property(type, value)
      end
    end

    def valid_custom_property_type?(type)
      CustomProperty.respond_to?(type.to_sym)
    end

    def build_custom_property(type, value)
      CustomProperty.send(type, value)
    end
  end
end
