# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
end

require 'yaml'
require 'vcr'
require File.expand_path('../lib/notion_to_md', __dir__)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :faraday

  # Redact the Notion token from the VCR cassettes
  config.before_record do |interaction|
    to_be_redacted = interaction.request.headers['Authorization']

    to_be_redacted.each do |redacted_text|
      interaction.filter!(redacted_text, '<REDACTED>')
    end

    sensitive_values = (ENV['NOTION_SENSITIVE_VALUES'] || '').split('|')
    replacement_values = (ENV['NOTION_SENSITIVE_REPLACEMENTS'] || '').split('|')
    sensitive_values.each_with_index do |sensitive_value, index|
      interaction.filter!(sensitive_value, replacement_values[index])
    end
  end

  config.default_cassette_options = {
    allow_playback_repeats: true,
    record: :new_episodes,
  }
end

NotionToMd::Logger.level = Logger::ERROR

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
