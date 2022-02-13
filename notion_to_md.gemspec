# frozen_string_literal: true

require_relative './lib/notion_to_md/version'

Gem::Specification.new do |s|
  s.name = 'notion_to_md'
  s.version = NotionToMd::VERSION
  s.summary = 'Notion Markdown Exporter'
  s.description = 'Notion Markdown Exporter in Ruby'
  s.authors = ['Enrique Arias']
  s.email = 'emoriarty81@gmail.com'
  s.files = Dir['lib/**/*.rb', 'README.md']
  s.homepage = 'https://github.com/emoriarty/notion_to_md'
  s.required_ruby_version = '>= 0'
  s.license = 'MIT'

  s.add_runtime_dependency('notion-ruby-client', '~> 0.0.8')

  s.add_development_dependency('hashie')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop')
end
