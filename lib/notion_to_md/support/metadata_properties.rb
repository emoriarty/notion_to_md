# frozen_string_literal: true

class NotionToMd
  module Support
    # === NotionToMd::Support::MetadataProperties
    #
    # Mixin module providing convenience accessors for Notion page or
    # database metadata. It extracts common properties (id, title, timestamps,
    # cover, icon, etc.) from the `metadata` hash returned by the Notion API.
    #
    # When included, this module delegates `#properties` to the `metadata`
    # attribute of the including class.
    #
    # @example Include in a model
    #   class Page
    #     include NotionToMd::Support::MetadataProperties
    #     attr_reader :metadata
    #   end
    #
    #   page = Page.new(metadata: notion_page_hash)
    #   page.title # => "My Notion Page"
    #
    # @see NotionToMd::MetadataType
    module MetadataProperties
      def self.included(base)
        base.extend Forwardable
        base.def_delegators :metadata, :properties
      end

      # @return [String] The Notion record ID.
      def id
        metadata[:id]
      end

      # Extract the page or database title.
      #
      # @return [String] Plain text concatenated from `title` property.
      def title
        title_list =
          metadata[:title] ||
          metadata.dig(:properties, :Name, :title) ||
          metadata.dig(:properties, :title, :title)

        title_list.inject('') do |acc, slug|
          acc + slug[:plain_text]
        end
      end

      # @return [Time] Creation timestamp.
      def created_time
        metadata[:created_time]
      end

      # @return [String, nil] Object type of creator.
      def created_by_object
        metadata.dig(:created_by, :object)
      end

      # @return [String, nil] ID of creator.
      def created_by_id
        metadata.dig(:created_by, :id)
      end

      # @return [Time] Last edited timestamp.
      def last_edited_time
        metadata[:last_edited_time]
      end

      # @return [String, nil] Object type of last editor.
      def last_edited_by_object
        metadata.dig(:last_edited_by, :object)
      end

      # @return [String, nil] ID of last editor.
      def last_edited_by_id
        metadata.dig(:last_edited_by, :id)
      end

      # @return [String] Public URL of the record.
      def url
        metadata[:url]
      end

      # @return [Boolean] Whether the record is archived.
      def archived
        metadata[:archived]
      end

      # Extract the cover image URL, from either external or file source.
      #
      # @return [String, nil] Cover URL or nil if not present.
      def cover
        MetadataType.external(metadata[:cover]) ||
          MetadataType.file(metadata[:cover])
      end

      # Extract the icon (emoji, external, or file).
      #
      # @return [String, nil] Icon value or nil if not present.
      def icon
        MetadataType.emoji(metadata[:icon]) ||
          MetadataType.external(metadata[:icon]) ||
          MetadataType.file(metadata[:icon])
      end
    end
  end
end
