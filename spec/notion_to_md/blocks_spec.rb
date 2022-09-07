# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks) do
  describe('permitted_children?') do
    context('when has children and is permitted') do
      let(:notion_block) { Hashie::Mash.new(has_children: true, type: 'numbered_list_item') }

      it { expect(described_class.permitted_children?(block: notion_block)).to be(true) }
    end

    context('when has children and is not permitted') do
      let(:notion_block) { Hashie::Mash.new(has_children: true, type: 'paragraph') }

      it { expect(described_class.permitted_children?(block: notion_block)).to be(false) }
    end

    context('when has no children and is not permitted') do
      let(:notion_block) { Hashie::Mash.new(has_children: false, type: 'paragraph') }

      it { expect(described_class.permitted_children?(block: notion_block)).to be(false) }
    end

    context('when has no children and is permitted') do
      let(:notion_block) { Hashie::Mash.new(has_children: false, type: 'numbered_list_item') }

      it { expect(described_class.permitted_children?(block: notion_block)).to be(false) }
    end
  end
end
