# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Converter) do
  let(:notion_token) { 'secret_0987654321' }
  let(:frontmatter) { false }
  let(:notion_client) do
    double('Notion::Client', block_children: NOTION_BLOCK_CHILDREN, page: NOTION_PAGE)
  end

  subject { described_class.new(page_id: 'd1535062-350e-45ec-93ba-c4b3d277f42a', frontmatter: frontmatter).convert }

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

    context('with frontmatter set true') do
      let(:frontmatter) { true }

      subject { described_class.new(page_id: 'd1535062-350e-45ec-93ba-c4b3d277f42a', frontmatter: frontmatter).convert }

      it 'document starts with ---' do
        expect(subject.split("\n").first).to matching(/^---$/)
      end

      it 'sets id in frontmatter' do
        expect(subject).to matching(/^id: 9dc17c9c-9d2e-469d-bbf0-f9648f3288d3$/)
      end

      it 'sets created_time in frontmatter' do
        expect(subject).to matching(/^created_time: 2022-01-23T12:31:00\+00:00/)
      end

      it 'sets last_edited_time in frontmatter' do
        expect(subject).to matching(/^last_edited_time: 2022-02-13T23:05:00\+00:00$/)
      end

      it 'sets icon in frontmatter' do
        expect(subject).to matching(/^icon: 💥$/)
      end

      it 'sets cover in frontmatter' do
        expect(subject).to matching(%r{^cover: https?://www.notion.so/images/page-cover/met_canaletto_1720.jpg$})
      end

      it 'sets title in frontmatter' do
        expect(subject).to matching(/^title: Page 1$/)
      end

      it 'sets archived in frontmatter' do
        expect(subject).to matching(/^archived: false$/)
      end

      it 'sets custom property multi_select type in frontmatter' do
        expect(subject).to matching(/^multi_select: \[mselect1, mselect2, mselect3\]$/)
      end

      it 'sets custom property select type in frontmatter' do
        expect(subject).to matching(/^select: select1$/)
      end

      it 'sets custom property people type in frontmatter' do
        expect(subject).to matching(/^person: \[John Rambo\]$/)
      end

      it 'sets custom property date type in frontmatter' do
        expect(subject).to matching(/^date: 2022-01-28$/)
      end

      it 'sets custom property number type in frontmatter' do
        expect(subject).to matching(/^numbers: 12$/)
      end

      it 'sets custom property files type in frontmatter' do
        expect(subject).to matching(%r{^file: \["https://s3.us-west-2.amazonaws.com/secure.notion-static.com/23e8b74e-86d1-4b3a-bd9a-dd0415a954e4/me.jpeg"\]$})
      end

      it 'sets custom property email type in frontmatter' do
        expect(subject).to matching(/^email: hola@test.com$/)
      end

      it 'sets custom property checkbox type in frontmatter' do
        expect(subject).to matching(/^checkbox: false$/)
      end
    end
  end
end
