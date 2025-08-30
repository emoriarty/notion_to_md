# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Page
  #
  # This class is responsible for representing a Notion page.
  class Page
    include Support::MetadataProperties
    include Support::Frontmatter

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
  end
end
