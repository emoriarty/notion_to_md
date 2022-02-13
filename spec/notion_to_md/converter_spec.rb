# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Converter) do
  let(:notion_token) { 'secret_0987654321' }
  let(:notion_client) do
    double('Notion::Client', block_children: NOTION_BLOCK_CHILDREN, page: NOTION_PAGE)
  end

  subject { described_class.new(page_id: 'd1535062-350e-45ec-93ba-c4b3d277f42a').convert }

  before do
    allow(ENV).to receive(:[]).with('NOTION_TOKEN').and_return(notion_token)
    allow(Notion::Client).to receive(:new).and_return(notion_client)
  end

  describe('convert') do
    it 'heading_1 to #' do
      expect(subject).to matching(/^# Heading 1$/)
    end

    it 'heading_2 to ##' do
      expect(subject).to matching(/^## Heading 2$/)
    end

    it 'heading_3 to ###' do
      expect(subject).to matching(/^### Heading 3$/)
    end

    it 'callout to emoji+text' do
      expect(subject).to matching(/^💡 Callout/)
    end

    it 'quote to >' do
      expect(subject).to matching(/^> Blablabla./)
    end

    it 'code to ```' do
      expect(subject).to matching(/^```$/)
    end

    it 'bulleted_list_item to - ' do
      expect(subject).to matching(/^- /)
    end

    it 'numbered_list_item to - ' do
      expect(subject).to matching(/^- /)
    end

    it 'to_do checked to - [x]' do
      expect(subject).to matching(/^- \[x\]/)
    end

    it 'to_do checked to - [ ]' do
      expect(subject).to matching(/^- \[ \]/)
    end

    it 'embed to [url](url)' do
      expect(subject).to matching(%r{^\[https?://\S+\]\(https?://\S+\)$})
    end

    it 'image with caption to ![url]\n\n(caption)' do
      expect(subject).to matching(%r{^!\[\]\(https?://\S+\)\s\sJohn Rambo having a coffee})
    end

    it 'bookmark to [url](url)' do
      expect(subject).to matching(%r{^\[https?://\S+\]\(https?://\S+\)$})
    end

    it 'divider to ---' do
      expect(subject).to matching(/^---$/)
    end

    it 'blank to <br />' do
      expect(subject).to matching(%r{^<br />})
    end

    it 'equation to $$ equ $$' do
      expect(subject).to matching(/\$\$ \S+ \$\$/)
    end

    it 'italic to *text*' do
      expect(subject).to matching(/^\*italic\*$/)
    end

    it 'bold to **text**' do
      expect(subject).to matching(/^\*\*bold\*\*$/)
    end

    it 'strike-trough to ~~text~~' do
      expect(subject).to matching(/^~~strike-trough~~$/)
    end

    it 'underline to <u>text</u>' do
      expect(subject).to matching(%r{^<u>underline</u>$})
    end

    it 'inline code to `text`' do
      expect(subject).to matching(/^`inline-code`$/)
    end
  end
end
