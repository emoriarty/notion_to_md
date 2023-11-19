# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::Builder) do
  describe('.permitted_children_for?') do
    context('when has children and is permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: true, type: 'numbered_list_item') }

      it { expect(described_class.permitted_children_for?(block: block_notion)).to be(true) }
    end

    context('when has children and is not permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: true, type: 'not_permitted_block') }

      it { expect(described_class.permitted_children_for?(block: block_notion)).to be(false) }
    end

    context('when has no children and is not permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: false, type: 'not_permitted_block') }

      it { expect(described_class.permitted_children_for?(block: block_notion)).to be(false) }
    end

    context('when has no children and is permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: false, type: 'numbered_list_item') }

      it { expect(described_class.permitted_children_for?(block: block_notion)).to be(false) }
    end

    it 'returns true for permitted block' do
      %w[bulleted_list_item numbered_list_item paragraph table to_do].each do |type|
        hashie_block = Hashie::Mash.new(type: type, has_children: true)
        expect(described_class.permitted_children_for?(block: hashie_block)).to be(true)
      end
    end
  end
end
