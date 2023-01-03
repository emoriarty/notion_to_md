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
  end

  describe('icon') do
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

    context('when is a file') do
      let(:url) { 'https://s3.us-west-2.amazonaws.com/secure.notion-static.com/X3f70b1X-2331-4012-99bc-24gcbd1c85sb/test.jpeg' }
      let(:notion_page) do
        {
          icon: {
            type: 'file',
            file: {
              url: url,
              expiry_time: '2022-07-30T10:12:33.218Z'
            }
          }
        }
      end

      it { expect(page.icon).to be(url) }
    end
  end
end
