# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::Normalizer) do
  describe('.normalize') do
    context('when has bulleted_list_item') do
      let(:blocks) do
        [
          instance_double(NotionToMd::Blocks::Block, type: 'bulleted_list_item')
        ]
      end

      it 'returns bulleted_list_item' do
        expect(described_class.normalize(blocks: blocks)).to contain_exactly(be_a_kind_of(NotionToMd::Blocks::BulletedListBlock))
      end
    end

    context('when has numbered_list_item') do
      let(:blocks) do
        [
          instance_double(NotionToMd::Blocks::Block, type: 'numbered_list_item'),
          instance_double(NotionToMd::Blocks::Block, type: 'numbered_list_item'),
          instance_double(NotionToMd::Blocks::Block, type: 'numbered_list_item')
        ]
      end

      it 'returns numbered_list_item' do
        expect(described_class.normalize(blocks: blocks)).to contain_exactly(be_a_kind_of(NotionToMd::Blocks::NumberedListBlock))
      end
    end

    context('when has to_do block') do
      let(:blocks) do
        [
          instance_double(NotionToMd::Blocks::Block, type: 'to_do'),
          instance_double(NotionToMd::Blocks::Block, type: 'to_do')
        ]
      end

      it 'returns to_do' do
        expect(described_class.normalize(blocks: blocks)).to contain_exactly(be_a_kind_of(NotionToMd::Blocks::ToDoListBlock))
      end
    end

    context('when has mixed types of blocks') do
      let(:blocks) do
        [
          instance_double(NotionToMd::Blocks::Block, type: 'bulleted_list_item'),
          instance_double(NotionToMd::Blocks::Block, type: 'numbered_list_item'),
          instance_double(NotionToMd::Blocks::Block, type: 'to_do')
        ]
      end

      it 'returns bulleted_list_item, numbered_list_item, to_do' do
        expect(described_class.normalize(blocks: blocks))
          .to contain_exactly(be_a_kind_of(NotionToMd::Blocks::BulletedListBlock),
                              be_a_kind_of(NotionToMd::Blocks::NumberedListBlock),
                              be_a_kind_of(NotionToMd::Blocks::ToDoListBlock))
      end
    end

    context('when has mixed types of blocks in different order') do
      let(:blocks) do
        [
          instance_double(NotionToMd::Blocks::Block, type: 'to_do'),
          instance_double(NotionToMd::Blocks::Block, type: 'paragraph', instance_of?: true),
          instance_double(NotionToMd::Blocks::Block, type: 'numbered_list_item'),
          instance_double(NotionToMd::Blocks::Block, type: 'paragraph', instance_of?: true),
          instance_double(NotionToMd::Blocks::Block, type: 'bulleted_list_item')
        ]
      end

      it 'returns to_do_list, paragraph, numbered_list, paragraph, bulleted_list' do
        expect(described_class.normalize(blocks: blocks))
          .to contain_exactly(
            be_a_kind_of(NotionToMd::Blocks::ToDoListBlock),
            be_a_kind_of(RSpec::Mocks::InstanceVerifyingDouble), # paragraph
            be_a_kind_of(NotionToMd::Blocks::NumberedListBlock),
            be_a_kind_of(RSpec::Mocks::InstanceVerifyingDouble), # paragraph
            be_a_kind_of(NotionToMd::Blocks::BulletedListBlock)
          )
      end
    end
  end
end
