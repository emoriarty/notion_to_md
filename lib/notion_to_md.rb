# frozen_string_literal: true

require 'notion'
require 'logger'
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'callee'
require_relative './notion_to_md/helpers'
require_relative './notion_to_md/version'
require_relative './notion_to_md/converter'
require_relative './notion_to_md/logger'
require_relative './notion_to_md/page_property'
require_relative './notion_to_md/page'
require_relative './notion_to_md/blocks'
require_relative './notion_to_md/text'
require_relative './notion_to_md/text_annotation'

class NotionToMd
  include Callee

  attr_reader :page_id, :token, :frontmatter

  def initialize(page_id:, token: nil, frontmatter: false)
    @page_id = page_id
    @token = token || ENV['NOTION_TOKEN']
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
    self.class.convert(page_id: page_id, token: token, frontmatter: frontmatter)
  end
end
