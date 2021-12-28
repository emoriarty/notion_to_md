require 'minitest/autorun' 
require 'notion'
require_relative '../../lib/notion_to_md'

describe NotionToMd::Converter do
  it 'converts to markdown' do
    notion = MiniTest::Mock.new
    notion.expect(:block_children, '')
    Notion::Client.stub :new, notion do
      notion
    end

    converter = NotionToMd::Converter.new(page_id: 'notion_page_id')
    output = converter.convert
    puts output
  end
end
