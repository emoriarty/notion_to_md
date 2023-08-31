# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Page) do
  subject(:page) { described_class.new(page: notion_page, blocks: notion_blocks) }

  let(:notion_page) { nil }
  let(:notion_blocks) { nil }

  describe('#custom_props') do
    context 'with a null select prop' do
      let(:notion_page) do
        Notion::Messages::Message.new(
          properties: {
            nil_select: { id: 'xxxx', type: 'select', select: nil }
          }
        )
      end

      it 'excludes the prop from the return' do
        expect(page.custom_props).not_to include('nil_select')
      end
    end

    context 'when "created_time" is a default property' do
      let(:default_date) { '2023-08-24' }
      let(:notion_page) do
        Notion::Messages::Message.new({
          created_time: default_date,
          last_edited_time: default_date,
          properties: {}
        })
      end

      it { expect(page.created_time).to eq(DateTime.parse(default_date)) }
    end

    context 'when "created_time" is overwritten by properties' do
      let(:default_date) { '2023-08-24' }
      let(:overwritten_date) { '2020-12-08' }
      let(:notion_page) do
        Notion::Messages::Message.new({
          created_time: default_date,
          last_edited_time: default_date,
          properties: {
            "Created time": {
              type: 'date',
              date: {
                start: overwritten_date
              }
            }
          }
        })
      end

      it { expect(page.created_time).to eq(DateTime.parse(overwritten_date)) }
    end
  end

  describe('#icon') do
    context('when is an emoji') do
      let(:emoji) { '\U0001F4A5' }
      let(:notion_page) do
        {
          icon: {
            type: 'emoji',
            emoji: emoji
          }
        }
      end

      it { expect(page.icon).to be(emoji) }
    end

    context('when is an external file') do
      let(:url) { 'https://s3.us-west-2.amazonaws.com/secure.notion-static.com/X3f70b1X-2331-4012-99bc-24gcbd1c85sb/test.jpeg' }
      let(:notion_page) do
        {
          icon: {
            type: 'external',
            external: {
              url: url,
              expiry_time: '2022-07-30T10:12:33.218Z'
            }
          }
        }
      end

      it { expect(page.icon).to be(url) }
    end
  end

  describe('#title') do
    let(:title) { 'Dummy title' }

    context('when the title is in the Name property') do
      let(:notion_page) do
        {
          properties: {
            Name: {
              type: 'title',
              title: [
                { plain_text: title }
              ]
            }
          }
        }
      end

      it { expect(page.title).to eq(title) }
    end

    context('when the title is in the title property') do
      let(:notion_page) do
        {
          properties: {
            title: {
              type: 'text',
              title: [
                { plain_text: title }
              ]
            }
          }
        }
      end

      it { expect(page.title).to eq(title) }
    end
  end
end
