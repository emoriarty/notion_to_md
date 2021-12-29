# frozen_string_literal: true

require 'minitest/autorun'
require 'notion'
require 'yaml'
require 'json'
require 'hashie'
require_relative '../../lib/notion_to_md'

class NotionOutput < Hashie::Mash
end

fixture = YAML.load_file("#{Dir.pwd}/test/fixtures/notion/block_children.yml")
NOTION_PAGE_ID = 'notion_page_id'

describe NotionToMd::Converter do
  before do
    @block_children = NotionOutput.new(JSON.parse(fixture['output']))
    @notion = MiniTest::Mock.new
    @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
  end

  describe 'when bold annotations' do
    it 'wraps with **' do
      @block_children[:results].each do |block|
        block[:paragraph][:text].each { |txt| txt[:annotations][:bold] = true }
      end

      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        output.split('\n\n').each do |line|
          assert line.start_with?('**')
          assert line.end_with?('**')
        end
      end
    end
  end

  it 'converts to markdown' do
    Notion::Client.stub :new, @notion do
      converter = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID)
      output = converter.convert
    end
  end
end
