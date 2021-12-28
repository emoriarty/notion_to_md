# frozen_string_literal: true

require_relative './lib/notion_to_md/version'

Gem::Specification.new do |s|
  s.name = 'notion_to_md'
  s.version = NotionToMd::VERSION
  s.summary = 'Notion Markdown Exporter'
  s.authors = ['emoriarty81@gmail.com']
  s.files = Dir['lib/**/*.rb', 'README.md']
  s.required_ruby_version = ">= #{File.read('.ruby-version').chomp}"

  s.add_runtime_dependency('notion-ruby-client')
end
