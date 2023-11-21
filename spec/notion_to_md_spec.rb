# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd) do
  let(:notion_token) { 'secret_0987654321' }
  let(:notion_client) do
    instance_double('Notion::Client', block_children: NOTION_BLOCK_CHILDREN, page: NOTION_PAGE)
  end

  before do
    allow(ENV).to receive(:[]).with('NOTION_TOKEN').and_return(notion_token)
    allow(Notion::Client).to receive(:new).and_return(notion_client)
  end

  describe('#convert') do
    subject(:md) { described_class.convert(page_id: 'd1535062-350e-45ec-93ba-c4b3d277f42a') }

    it 'document does not start with ---' do
      expect(md.split("\n").first).not_to matching(/^---$/)
    end

    it 'heading_1 to #' do
      expect(md).to matching(/^# Heading 1$/)
    end

    it 'heading_2 to ##' do
      expect(md).to matching(/^## Heading 2$/)
    end

    it 'heading_3 to ###' do
      expect(md).to matching(/^### Heading 3$/)
    end

    it 'callout to emoji+text' do
      expect(md).to matching(/^> 💡 Callout/)
    end

    it 'quote to >' do
      expect(md).to matching(/^> Blablabla./)
    end

    it 'code to ```' do
      expect(md).to matching(/^```$/)
    end

    it 'bulleted_list_item to - ' do
      expect(md).to matching(/^- /)
    end

    it 'numbered_list_item to - ' do
      expect(md).to matching(/^- /)
    end

    it 'to_do checked to - [x]' do
      expect(md).to matching(/^- \[x\]/)
    end

    it 'to_do checked to - [ ]' do
      expect(md).to matching(/^- \[ \]/)
    end

    it 'embed to [url](url)' do
      expect(md).to matching(%r{^\[https?://\S+\]\(https?://\S+\)$})
    end

    it 'image with caption to ![url]\n\n(caption)' do
      expect(md).to matching(%r{^!\[\]\(https?://\S+\)\s\sJohn Rambo having a coffee})
    end

    it 'bookmark to [url](url)' do
      expect(md).to matching(%r{^\[https?://\S+\]\(https?://\S+\)$})
    end

    it 'divider to ---' do
      expect(md).to matching(/^---$/)
    end

    it 'blank to <br />' do
      expect(md).to matching(%r{^<br />})
    end

    it 'equation to $$ equ $$' do
      expect(md).to matching(/\$\$ \S+ \$\$/)
    end

    it 'italic to *text*' do
      expect(md).to matching(/^\*italic\*$/)
    end

    it 'bold to **text**' do
      expect(md).to matching(/^\*\*bold\*\*$/)
    end

    it 'strike-trough to ~~text~~' do
      expect(md).to matching(/^~~strike-trough~~$/)
    end

    it 'underline to <u>text</u>' do
      expect(md).to matching(%r{^<u>underline</u>$})
    end

    it 'inline code to `text`' do
      expect(md).to matching(/^`inline-code`$/)
    end

    context('with frontmatter') do
      subject(:md) do
        described_class.convert(page_id: 'd1535062-350e-45ec-93ba-c4b3d277f42a', frontmatter: frontmatter)
      end

      let(:frontmatter) { true }

      it 'document starts with ---' do
        expect(md.split("\n").first).to matching(/^---$/)
      end

      it 'sets id in frontmatter' do
        expect(md).to matching(/^id: 9dc17c9c-9d2e-469d-bbf0-f9648f3288d3$/)
      end

      it 'sets created_time in frontmatter' do
        expect(md).to matching(/^created_time: 2022-01-23T12:31:00\+00:00/)
      end

      it 'sets last_edited_time in frontmatter' do
        expect(md).to matching(/^last_edited_time: 2022-04-03T02:29:00\+00:00$/)
      end

      it 'sets icon in frontmatter' do
        expect(md).to matching(/^icon: 💥$/)
      end

      it 'sets cover in frontmatter' do
        expect(md).to matching(%r{^cover: https?://www.notion.so/images/page-cover/met_canaletto_1720.jpg$})
      end

      it 'sets title in frontmatter' do
        expect(md).to matching(/^title: Page 1$/)
      end

      it 'sets archived in frontmatter' do
        expect(md).to matching(/^archived: false$/)
      end

      it 'sets custom property multi_select type in frontmatter' do
        expect(md).to matching(/^multi_select: \["mselect1", "mselect2", "mselect3"\]$/)
      end

      it 'sets custom property select type in frontmatter' do
        expect(md).to matching(/^select: select1$/)
      end

      it 'sets custom property people type in frontmatter' do
        expect(md).to matching(/^person: \["John Rambo"\]$/)
      end

      it 'sets custom property date type in frontmatter' do
        expect(md).to matching(/^date: 2022-01-28$/)
      end

      it 'sets custom property number type in frontmatter' do
        expect(md).to matching(/^numbers: 12$/)
      end

      it 'sets custom property files type in frontmatter' do
        expect(md).to matching(%r{^file: \["https://s3.us-west-2.amazonaws.com/secure.notion-static.com/23e8b74e-86d1-4b3a-bd9a-dd0415a954e4/me.jpeg"\]$})
      end

      it 'sets custom property email type in frontmatter' do
        expect(md).to matching(/^email: hola@test.com$/)
      end

      it 'sets custom property checkbox type in frontmatter' do
        expect(md).to matching(/^checkbox: false$/)
      end

      it 'sets custom property rich_text type in frontmatter' do
        expect(md).to matching(/^rich_text: This is a rich_text property. With Italics.$/)
      end
    end
  end
end
