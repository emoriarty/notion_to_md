# frozen_string_literal: true

require 'spec_helper'

# spec support dummy
class DummyClass
  include NotionToMd::Support::MetadataProperties
  include NotionToMd::Support::Frontmatter

  attr_reader :metadata, :children
  alias blocks children

  def initialize(metadata:, children:)
    @metadata = metadata
    @children = children
  end
end

RSpec.describe NotionToMd::Support::Frontmatter do
  subject(:dummy) { DummyClass.new(metadata: metadata, children: blocks) }

  let(:metadata) { nil }
  let(:blocks) { nil }

  describe('#frontmatter') do
    let(:metadata) do
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
              { plain_text: 'Title: with "double quotes" and \'single quotes\' and: :colons:' }
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
      expect { YAML.safe_load(dummy.frontmatter, permitted_classes: [Time]) }.not_to raise_error
    end

    it 'includes the title' do
      expect(YAML.safe_load(dummy.frontmatter,
                            permitted_classes: [Time])['title']).to eq('Title: with "double quotes" and \'single quotes\' and: :colons:')
    end

    it 'includes the cover' do
      expect(YAML.safe_load(dummy.frontmatter, permitted_classes: [Time])['cover']).to eq('https://s3.us-west-2.amazonaws.com/secure.notion-static.com/X3f70b1X-2331-4012-99bc-24gcbd1c85sb/test.jpeg')
    end

    it 'includes the icon' do
      expect(YAML.safe_load(dummy.frontmatter, permitted_classes: [Time])['icon']).to eq('\U0001F4A5')
    end

    it 'includes the created_time' do
      expect(YAML.safe_load(dummy.frontmatter, permitted_classes: [Time])['created_time']).to be_within(1).of(Time.now)
    end

    it 'includes the last_edited_time' do
      expect(YAML.safe_load(dummy.frontmatter,
                            permitted_classes: [Time])['last_edited_time']).to be_within(1).of(Time.now)
    end

    it 'includes the archived' do
      expect(YAML.safe_load(dummy.frontmatter, permitted_classes: [Time])['archived']).to be(false)
    end

    context 'when the title contains colons' do
      let(:metadata) do
        Notion::Messages::Message.new(
          properties: {
            title: {
              type: 'text',
              title: [
                { plain_text: 'Title: with: :colons : :' }
              ]
            }
          }
        )
      end

      it 'escapes the colons' do
        expect(YAML.safe_load(dummy.frontmatter, permitted_classes: [Time])['title']).to eq('Title: with: :colons : :')
      end
    end

    context 'when the title contains double quotes' do
      let(:metadata) do
        Notion::Messages::Message.new(
          properties: {
            title: {
              type: 'text',
              title: [
                { plain_text: 'Title with "double quotes"' }
              ]
            }
          }
        )
      end

      it 'escapes the double quotes' do
        expect(YAML.safe_load(dummy.frontmatter, permitted_classes: [Time])['title']).to eq('Title with "double quotes"')
      end
    end

    context 'when the title contains hyphens' do
      let(:metadata) do
        Notion::Messages::Message.new(
          properties: {
            title: {
              type: 'text',
              title: [
                { plain_text: '- Title with -hyphens- -' }
              ]
            }
          }
        )
      end

      it 'does not escape the hyphens' do
        expect(YAML.safe_load(dummy.frontmatter, permitted_classes: [Time])['title']).to eq('- Title with -hyphens- -')
      end
    end

    context 'when the title contains diacritics' do
      let(:metadata) do
        Notion::Messages::Message.new(
          properties: {
            title: {
              type: 'text',
              title: [
                { plain_text: 'Title with diacritics àáâãäāăȧǎȁȃ' }
              ]
            }
          }
        )
      end

      it 'does not escape the diacritics' do
        expect(YAML.safe_load(dummy.frontmatter,
                              permitted_classes: [Time])['title']).to eq('Title with diacritics àáâãäāăȧǎȁȃ')
      end
    end
  end
end
