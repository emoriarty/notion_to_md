# frozen_string_literal: true

class NotionToMd
  module Support
    module MetadataProperties
      def self.included(base)
        base.extend Forwardable
        base.def_delegators :metadata, :properties
      end

      def id
        metadata[:id]
      end

      def title
        title_list = metadata[:title] || metadata.dig(:properties, :Name, :title) || metadata.dig(:properties, :title, :title)
        title_list.inject('') do |acc, slug|
          acc + slug[:plain_text]
        end
      end

      def created_time
        metadata[:created_time]
      end

      def created_by_object
        metadata.dig(:created_by, :object)
      end

      def created_by_id
        metadata.dig(:created_by, :id)
      end

      def last_edited_time
        metadata[:last_edited_time]
      end

      def last_edited_by_object
        metadata.dig(:last_edited_by, :object)
      end

      def last_edited_by_id
        metadata.dig(:last_edited_by, :id)
      end

      def url
        metadata[:url]
      end

      def archived
        metadata[:archived]
      end

      def cover
        MetadataType.external(metadata[:cover]) || MetadataType.file(metadata[:cover])
      end

      def icon
        MetadataType.emoji(metadata[:icon]) || MetadataType.external(metadata[:icon]) || MetadataType.file(metadata[:icon])
      end
    end
  end
end
