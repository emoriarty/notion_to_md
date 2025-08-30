# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Database
  #
  # This class represents Notion Database object.
  class Database
    include Support::MetadataProperties

    class << self
      def call(id:, notion_client:, filter: nil, sorts: nil, frontmatter: false)
        metadata = notion_client.database(database_id: id)
        pages = Builder.call(database_id: id, notion_client: notion_client, filter: filter, sorts: sorts, frontmatter: frontmatter)

        new(metadata: metadata, children: pages)
      end

      alias build call
    end

    attr_reader :metadata, :children

    alias pages children

    def initialize(metadata:, children:)
      @metadata = metadata
      @children = children
    end

    def to_s
      pages.map(&:to_s)
    end

    alias to_md to_s
  end
end
