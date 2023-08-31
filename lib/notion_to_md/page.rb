# frozen_string_literal: true

module NotionToMd
  class Page
    attr_reader :page, :blocks

    def initialize(page:, blocks:)
      @page = page
      @blocks = blocks
    end

    def title
      title_list = page.dig(:properties, :Name, :title) || page.dig(:properties, :title, :title)
      title_list.inject('') do |acc, slug|
        acc + slug[:plain_text]
      end if title_list
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
      if custom_props['created_time']
        DateTime.parse(custom_props['created_time'])
      else
        DateTime.parse(page['created_time'])
      end
    end

    def last_edited_time
      if custom_props['last_edited_time']
        DateTime.parse(custom_props['last_edited_time'])
      else
        DateTime.parse(page['last_edited_time'])
      end
    end

    def url
      page[:url]
    end

    def archived
      page[:archived]
    end

    def body
      @body ||= blocks.map(&:to_md).compact.join("\n\n")
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
      @custom_props ||= page.properties.each_with_object({}) do |prop, memo|
        name = prop.first
        value = prop.last # Notion::Messages::Message
        type = value.type

        next memo unless CustomProperty.respond_to?(type.to_sym)

        memo[name.parameterize.underscore] = CustomProperty.send(type, value)
      end.reject { |_k, v| v.presence.nil? }
    end

    def default_props
      @default_props ||= {
        'id' => id,
        'title' => title,
        'created_time' => created_time,
        'cover' => cover,
        'icon' => icon,
        'last_edited_time' => last_edited_time,
        'archived' => archived
      }
    end

    # This class is kept for retro compatibility reasons.
    # Use instead the PageProperty class.
    class CustomProperty < PageProperty
    end
  end
end
