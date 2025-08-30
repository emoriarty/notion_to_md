# frozen_string_literal: true

require 'notion'
require 'logger'
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'zeitwerk'

# Load the NotionToMd classes using Zeitwerk
loader = Zeitwerk::Loader.for_gem
loader.setup

##
# The {NotionToMd} class is the main entry point for converting
# Notion pages and databases into Markdown documents.
#
# It provides a single class method {.call} (aliased as {.convert})
# that accepts a Notion resource type (`:page` or `:database`), an ID,
# and options to control conversion.
#
# @example Convert a single Notion page to Markdown
#   markdown = NotionToMd.call(:page, id: "xxxx-xxxx", token: "secret_token")
#
# @example Convert a Notion database to Markdown and yield the result
#   NotionToMd.convert(:database, id: "xxxx-xxxx").each_with_index do |md, index|
#     File.write("output_#{index}.md", md)
#   end
#
class NotionToMd
  ##
  # Supported resource types for conversion.
  #
  # @return [Hash{Symbol => Symbol}] mapping of friendly keys to types
  TYPES = { database: :database, page: :page }.freeze

  class << self
    ##
    # Convert a Notion resource (page or database) to Markdown.
    #
    # @param type [Symbol] the type of Notion resource (`:page` or `:database`).
    # @param id [String] the Notion page or database ID.
    # @param token [String, nil] the Notion API token.
    #   If omitted, defaults to `ENV['NOTION_TOKEN']`.
    # @param frontmatter [Boolean] whether to include YAML frontmatter
    #   in the generated Markdown.
    #
    # @yield [md] optional block to handle the generated Markdown.
    # @yieldparam md [String] the Markdown output.
    #
    # @return [String] the Markdown representation of the Notion resource.
    #
    # @raise [RuntimeError] if the given +type+ is not supported.
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

    ##
    # Alias for {.call}.
    #
    # @see .call
    #
    def convert(type, id:, token: nil, frontmatter: false, &block)
      call(type, id: id, token: token, frontmatter: frontmatter, &block)
    end
  end
end
