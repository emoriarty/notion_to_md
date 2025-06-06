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

  s.add_runtime_dependency('activesupport', '~> 7')
  s.add_runtime_dependency('callee', '~> 0.3.6')
  s.add_runtime_dependency('notion-ruby-client', '~> 1')
  s.add_runtime_dependency('zeitwerk', '~> 2.6')

  s.add_development_dependency('hashie')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('rubocop-rspec')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('vcr')
end
