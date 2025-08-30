# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Page
  #
  # This class is responsible for representing a Notion page.
  class Page
    include Support::MetadataProperties
    include Support::Frontmatter

    class << self
      def call(id:, notion_client:, frontmatter: false)
        metadata = notion_client.page(page_id: id)
        blocks = Blocks::Builder.call(block_id: id, notion_client: notion_client)

        new(metadata: metadata, children: blocks, frontmatter: frontmatter)
      end

      alias build call
    end

    attr_reader :metadata, :children

    alias blocks children

    def initialize(metadata:, children:, frontmatter: false)
      @metadata = metadata
      @children = children
      @config = { frontmatter: frontmatter }
    end

    def body
      @body ||= blocks.map(&:to_md).compact.join
    end

    def frontmatter?
      @config[:frontmatter]
    end

    def to_s
      <<~MD
        #{frontmatter if frontmatter?}
        #{body}
      MD
    end

    alias to_md to_s
  end
end
