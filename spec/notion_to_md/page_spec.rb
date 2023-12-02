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

  describe("#frontmatter") do
    let(:notion_page) do
      Notion::Messages::Message.new(
        id: 'xxxx',
        cover: {
          type: 'external',
          external: {
            url: 'https://s3.us-west-2.amazonaws.com/secure.notion-static.com/X3f70b1X-2331-4012-99bc-24gcbd1c85sb/test.jpeg',
            expiry_time: '2022-07-30T10:12:33.218Z'
          }
        },
        icon: {
          type: 'emoji',
          emoji: '\U0001F4A5'
        },
        created_time: Time.now,
        last_edited_time: Time.now,
        archived: false,
        properties: {
          title: {
            type: 'text',
            title: [
              { plain_text: 'Title with "double quotes" and \'single quotes\' and: :colons:' }
            ]
          },
          rich_text: {
            type: 'rich_text',
            rich_text: [
              { plain_text: 'Rich text with "double quotes" and \'single quotes\' and: :colons:' }
            ]
          },
          select: {
            type: 'select',
            select: {
              name: 'Select with "double quotes" and \'single quotes\' and: :colons:'
            }
          },
          multi_select: {
            type: 'multi_select',
            multi_select: [
              {
                name: 'Multi select with "double quotes" and \'single quotes\' and: :colons:'
              }
            ]
          }
        }
      )
    end

    it 'validates frontmatter' do
      expect { YAML.safe_load(page.frontmatter, permitted_classes: [Time]) }.not_to raise_error
    end

    it 'includes the title' do
      expect(YAML.safe_load(page.frontmatter, permitted_classes: [Time])['title']).to eq('Title with "double quotes" and \'single quotes\' and: :colons:')
    end

    it 'includes the cover' do
      expect(YAML.safe_load(page.frontmatter, permitted_classes: [Time])['cover']).to eq('https://s3.us-west-2.amazonaws.com/secure.notion-static.com/X3f70b1X-2331-4012-99bc-24gcbd1c85sb/test.jpeg')
    end

    it 'includes the icon' do
      expect(YAML.safe_load(page.frontmatter, permitted_classes: [Time])['icon']).to eq('\U0001F4A5')
    end

    it 'includes the created_time' do
      expect(YAML.safe_load(page.frontmatter, permitted_classes: [Time])['created_time']).to be_within(1).of(Time.now)
    end

    it 'includes the last_edited_time' do
      expect(YAML.safe_load(page.frontmatter, permitted_classes: [Time])['last_edited_time']).to be_within(1).of(Time.now)
    end

    it 'includes the archived' do
      expect(YAML.safe_load(page.frontmatter, permitted_classes: [Time])['archived']).to eq(false)
    end
  end
end
