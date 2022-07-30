# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
end

require 'yaml'
require File.expand_path('../lib/notion_to_md', __dir__)

NotionToMd::Logger.level = Logger::ERROR

NOTION_PAGE = YAML.load_file(File.expand_path('fixtures/notion_page.yml', __dir__))
NOTION_BLOCK_CHILDREN = YAML.load_file(File.expand_path('fixtures/notion_block_children.yml', __dir__))

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
