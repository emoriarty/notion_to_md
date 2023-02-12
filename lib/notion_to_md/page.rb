# frozen_string_literal: true

module NotionToMd
  class Page
    attr_reader :page, :blocks

    def initialize(page:, blocks:)
      @page = page
      @blocks = blocks
    end

    def title
      page.dig(:properties, :Name, :title).inject('') do |acc, slug|
        acc + slug[:plain_text]
      end
    end

    def cover
      Property.external(page[:cover]) || Property.file(page[:cover])
    end

    def icon
      Property.emoji(page[:icon]) || Property.external(page[:cover]) || Property.file(page[:cover])
    end

    def id
      page[:id]
    end

    def created_time
      DateTime.parse(page['created_time'])
    end

    def last_edited_time
      DateTime.parse(page['last_edited_time'])
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

        next memo unless Property.respond_to?(type.to_sym)

        memo[name.parameterize.underscore] = Property.send(type, value)
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
  end
end
