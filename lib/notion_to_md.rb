# frozen_string_literal: true

require 'notion'
require 'logger'
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'callee'
require 'zeitwerk'

# Load the NotionToMd classes using Zeitwerk
loader = Zeitwerk::Loader.for_gem
loader.setup

# The NotionToMd class allows to transform notion pages to markdown documents.
class NotionToMd
  include Callee

  attr_reader :page_id, :token, :frontmatter

  def initialize(page_id:, token: nil, frontmatter: false)
    @page_id = page_id
    @token = token || ENV.fetch('NOTION_TOKEN', nil)
    @frontmatter = frontmatter
  end

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
  def self.convert(page_id:, token: nil, frontmatter: false)
    Converter.new(page_id: page_id, token: token).convert(frontmatter: frontmatter)
  end

  def call
    md = self.class.convert(page_id: page_id, token: token, frontmatter: frontmatter)

    yield md if block_given?

    md
  end
end
