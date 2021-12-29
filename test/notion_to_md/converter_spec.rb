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
  describe 'when text annotations' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['paragraph']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    describe 'with bold' do
      before do
        @block_children[:results].each do |block|
          block[:paragraph][:text].each { |txt| txt[:annotations][:bold] = true }
        end
      end

      it 'wraps with **' do
        Notion::Client.stub :new, @notion do
          output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
          assert output.start_with?('**')
          assert output.end_with?('**')
        end
      end
    end

    describe 'with italic' do
      before do
        @block_children[:results].each do |block|
          block[:paragraph][:text].each { |txt| txt[:annotations][:italic] = true }
        end
      end

      it 'wraps with *' do
        Notion::Client.stub :new, @notion do
          output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
          assert output.start_with?('*')
          assert output.end_with?('*')
        end
      end
    end

    describe 'with striketrough' do
      before do
        @block_children[:results].each do |block|
          block[:paragraph][:text].each { |txt| txt[:annotations][:striketrough] = true }
        end
      end

      it 'wraps with ~~' do
        Notion::Client.stub :new, @notion do
          output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
          assert output.start_with?('~~')
          assert output.end_with?('~~')
        end
      end
    end

    describe 'with code' do
      before do
        @block_children[:results].each do |block|
          block[:paragraph][:text].each { |txt| txt[:annotations][:code] = true }
        end
      end

      it 'wraps with `' do
        Notion::Client.stub :new, @notion do
          output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
          assert output.start_with?('`')
          assert output.end_with?('`')
        end
      end
    end
  end

  describe 'when heading_1 block' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['heading_1']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'starts with # ' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.start_with?('# ')
      end
    end
  end

  describe 'when heading_2 block' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['heading_2']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'starts with ## ' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.start_with?('## ')
      end
    end
  end

  describe 'when heading_3 block' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['heading_3']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'starts with ### ' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.start_with?('### ')
      end
    end
  end

  describe 'when quote block' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['quote']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'starts with > ' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.start_with?('> ')
      end
    end
  end

  describe 'when code block' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['code']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'wrapped by ```' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.start_with?('```')
        assert output.end_with?('```')
      end
    end
  end

  describe 'when equation block' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['equation']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'wrapped by $$' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.start_with?('$$')
        assert output.end_with?('$$')
      end
    end
  end

  describe 'when bulleted_list_item block' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['bulleted_list_item']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'starts with $$' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.start_with?('- ')
      end
    end
  end

  describe 'when to_do block' do
    describe 'when checked' do
      before do
        @block_children = NotionOutput.new(JSON.parse(fixture['to_do']))
        @block_children[:results].each do |block|
          block[:to_do][:checked] = true
        end
        @notion = MiniTest::Mock.new
        @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
      end

      it 'starts with ' do
        Notion::Client.stub :new, @notion do
          output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
          assert output.start_with?('- [x]')
        end
      end
    end

    describe 'when not checked' do
      before do
        @block_children = NotionOutput.new(JSON.parse(fixture['to_do']))
        @block_children[:results].each do |block|
          block[:to_do][:checked] = false
        end
        @notion = MiniTest::Mock.new
        @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
      end

      it 'starts with ' do
        Notion::Client.stub :new, @notion do
          output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
          assert output.start_with?('- [ ]')
        end
      end
    end
  end

  describe 'when link' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['paragraph']))
      @block_children[:results].each do |block|
        block[:paragraph][:href] = 'http://site.test'
      end
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'starts with $$' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.match?(/[\w+](\w+)/)
      end
    end
  end


  describe 'when unsupported block' do
    before do
      @block_children = NotionOutput.new(JSON.parse(fixture['file']))
      @notion = MiniTest::Mock.new
      @notion.expect(:block_children, @block_children, [{ id: NOTION_PAGE_ID }])
    end

    it 'returns nothing' do
      Notion::Client.stub :new, @notion do
        output = NotionToMd::Converter.new(page_id: NOTION_PAGE_ID).convert
        assert output.empty?
      end
    end
  end
end
