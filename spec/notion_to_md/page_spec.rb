
# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Page) do
  let(:notion_page) { nil }
  let(:notion_blocks) { nil }

  subject { described_class.new(page: notion_page, blocks: notion_blocks) }

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

      it { expect(subject.icon).to be(emoji) }
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

      it { expect(subject.icon).to be(url) }
    end
  end
end