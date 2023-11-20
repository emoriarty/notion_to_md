# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::Normalizer) do
  describe('.normalize') do
    context('when has bulleted_list_item') do
      let(:blocks) do
        [
          instance_double(NotionToMd::Blocks::Block, type: 'bulleted_list_item'),
          instance_double(NotionToMd::Blocks::Block, type: 'bulleted_list_item')
        ]
      end

      it 'returns bulleted_list_item' do
        expect(described_class.normalize(blocks: blocks)).to include(be_a_kind_of(NotionToMd::Blocks::BulletedListBlock))
      end
    end
  end
end
