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
    def call(page_id:, token: nil, frontmatter: false)
      md = Converter.call(page_id: page_id, token: token || ENV.fetch('NOTION_TOKEN', nil), frontmatter: frontmatter)

      yield md if block_given?

      md
    end

    alias convert call
  end
end
