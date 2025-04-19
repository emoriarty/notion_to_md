# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Page
  #
  # This class is responsible for representing a Notion page.
  class Page
    include Helpers::YamlSanitizer

    attr_reader :page, :blocks

    def initialize(page:, blocks:)
      @page = page
      @blocks = blocks
    end

    def title
      title_list = page.dig(:properties, :Name, :title) || page.dig(:properties, :title, :title)
      title_list.inject('') do |acc, slug|
        acc + slug[:plain_text]
      end
    end

    def cover
      PageProperty.external(page[:cover]) || PageProperty.file(page[:cover])
    end

    def icon
      PageProperty.emoji(page[:icon]) || PageProperty.external(page[:icon]) || PageProperty.file(page[:icon])
    end

    def id
      page[:id]
    end

    def created_time
      page['created_time']
    end

    def created_by_object
      page.dig(:created_by, :object)
    end

    def created_by_id
      page.dig(:created_by, :id)
    end

    def last_edited_time
      page['last_edited_time']
    end

    def last_edited_by_object
      page.dig(:last_edited_by, :object)
    end

    def last_edited_by_id
      page.dig(:last_edited_by, :id)
    end

    def url
      page[:url]
    end

    def archived
      page[:archived]
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
    # Use instead the PageProperty class.
    class CustomProperty < PageProperty
    end

    private

    def filtered_custom_properties
      build_custom_properties.reject { |_k, v| v.presence.nil? }
    end

    def build_custom_properties
      page.properties.each_with_object({}) do |(name, value), memo|
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
