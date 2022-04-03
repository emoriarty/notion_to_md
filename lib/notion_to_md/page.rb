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
      page.dig(:cover, :external, :url)
    end

    def icon
      page.dig(:icon, :emoji)
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
      @body ||= blocks[:results].map do |block|
        next Block.blank if block[:type] == 'paragraph' && block.dig(:paragraph, :rich_text).empty?

        block_type = block[:type].to_sym

        begin
          Block.send(block_type, block[block_type])
        rescue StandardError
          Logger.info("Unsupported block type: #{block_type}")
          next nil
        end
      end.compact.join("\n\n")
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

    class CustomProperty
      class << self
        def multi_select(prop)
          prop.multi_select.map(&:name)
        end

        def select(prop)
          prop['select'].name
        end

        def people(prop)
          prop.people.map(&:name)
        end

        def files(prop)
          prop.files.map { |f| f.file.url }
        end

        def phone_number(prop)
          prop.phone_number
        end

        def number(prop)
          prop.number
        end

        def email(prop)
          prop.email
        end

        def checkbox(prop)
          prop.checkbox.to_s
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
end
