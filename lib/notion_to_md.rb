# frozen_string_literal: true

require 'notion'
require 'logger'
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'zeitwerk'

# Load the NotionToMd classes using Zeitwerk
loader = Zeitwerk::Loader.for_gem
loader.setup

# The NotionToMd class allows to transform notion pages to markdown documents.
class NotionToMd
  TYPES = { database: :database, page: :page }.freeze

  class << self
    # === Parameters
    # page_id::
    #   A string representing the notion page id.
    # token::
    #   The notion API secret token. The token can replaced by the environment variable NOTION_TOKEN.
    # frontmatter::
    #   A boolean indicating whether to include the page properties as frontmatter.
    #
    # === Returns
    # The string that represent the markdown document.
    #
    def call(type, id:, token: nil, frontmatter: false)
      raise "#{type} is not supported. Use :database or :page" unless TYPES.values.include?(type)

      notion_client = Notion::Client.new(token: token || ENV.fetch('NOTION_TOKEN', nil))
      md = case type
           when TYPES[:database]
             Database.call(id: id, notion_client: notion_client, frontmatter: frontmatter).to_md
           when TYPES[:page]
             Page.call(id: id, notion_client: notion_client, frontmatter: frontmatter).to_md
           end

      yield md if block_given?

      md
    end

    alias convert call
  end
end
