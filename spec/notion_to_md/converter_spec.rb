# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Converter) do
  let(:token) { ENV.fetch('NOTION_TOKEN', nil) }
  let(:page_id) { '25adb135281c80828cb1dc59437ae243' }

  before do
    VCR.insert_cassette('a_very_long_notion_page')
  end

  after do
    VCR.eject_cassette('a_very_long_notion_page')
  end

  describe('#convert') do
    it 'returns the markdown document' do
      expect(described_class.new(page_id: page_id).convert)
        .to start_with("\nLorem ipsum dolor sit amet")
        .and end_with("tempor nec odio.\n\n\n")
    end
  end

  describe('.call') do
    it 'returns the markdown document' do
      expect(described_class.call(page_id: page_id))
        .to start_with("\nLorem ipsum dolor sit amet")
        .and end_with("tempor nec odio.\n\n\n")
    end

    it 'returns the markdown document with frontmatter' do
      expect(described_class.call(page_id: page_id, frontmatter: true))
        .to start_with("---\n")
        .and end_with("tempor nec odio.\n\n\n")
    end

    context('with a block') do
      it 'returns the markdown document' do
        output = nil

        described_class.call(page_id: page_id) { output = _1 }

        expect(output)
          .to start_with("\nLorem ipsum dolor sit amet")
          .and end_with("tempor nec odio.\n\n\n")
      end

      it 'returns the markdown document with frontmatter' do
        output = nil

        described_class.call(page_id: page_id, frontmatter: true) { output = _1 }

        expect(output)
          .to start_with("---\n")
          .and end_with("tempor nec odio.\n\n\n")
      end
    end
  end
end
