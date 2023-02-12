# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Property) do
  subject(:page) { described_class.new(page: notion_page, blocks: notion_blocks) }

  let(:notion_page) { nil }
  let(:notion_blocks) { nil }

  describe('.file') do
    let(:file_prop) { { file: { url: 'https://example.com' } } }

    it { expect(described_class.file(file_prop)).to eq('https://example.com') }

    context('when nil') do
      let(:file_prop) { { file: nil } }

      it { expect(described_class.file(file_prop)).to be_nil }
    end
  end

  describe('.external') do
    let(:external_prop) { { external: { url: 'https://example.com' } } }

    it { expect(described_class.external(external_prop)).to eq('https://example.com') }

    context('when nil') do
      let(:external_prop) { { external: nil } }

      it { expect(described_class.external(external_prop)).to be_nil }
    end
  end

  describe('.emoji') do
    let(:emoji_prop) { { emoji: '😀' } }

    it { expect(described_class.emoji(emoji_prop)).to eq('😀') }
  end

  describe('.multi_select') do
    let(:multi_select_prop) { { multi_select: [{ name: 'name_1' }, { name: 'name_2' }, { name: 'name_3' }] } }

    it { expect(described_class.multi_select(multi_select_prop)).to eq(%w[name_1 name_2 name_3]) }
  end

  describe('.select') do
    let(:select_prop) { { select: { name: 'name_1' } } }

    it { expect(described_class.select(select_prop)).to eq('name_1') }
  end

  describe('.people') do
    let(:people_prop) { { people: [{ name: 'name_1' }, { name: 'name_2' }, { name: 'name_3' }] } }

    it { expect(described_class.people(people_prop)).to eq(%w[name_1 name_2 name_3]) }
  end

  describe('.files') do
    let(:files_prop) { { files: [{ file: { url: 'https://example_1.com' } }, { file: { url: 'https://example_2.com' } }] } }

    it { expect(described_class.files(files_prop)).to eq(%w[https://example_1.com https://example_2.com]) }

    context('when files are external') do
      let(:files_prop) { { files: [{ external: { url: 'https://example_1.com' } }, { external: { url: 'https://example_2.com' } }] } }

      it { expect(described_class.files(files_prop)).to eq(%w[https://example_1.com https://example_2.com]) }
    end
  end
end
