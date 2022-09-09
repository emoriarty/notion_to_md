# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks) do
  describe('permitted_children?') do
    context('when has children and is permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: true, type: 'numbered_list_item') }

      it { expect(described_class.permitted_children?(block: block_notion)).to be(true) }
    end

    context('when has children and is not permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: true, type: 'paragraph') }

      it { expect(described_class.permitted_children?(block: block_notion)).to be(false) }
    end

    context('when has no children and is not permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: false, type: 'paragraph') }

      it { expect(described_class.permitted_children?(block: block_notion)).to be(false) }
    end

    context('when has no children and is permitted') do
      let(:block_notion) { Hashie::Mash.new(has_children: false, type: 'numbered_list_item') }

      it { expect(described_class.permitted_children?(block: block_notion)).to be(false) }
    end
  end

  describe('build') do
    let(:page_notion) do
      Hashie::Mash.new(
        type: block_type,
        has_children: true,
        id: 1,
        results: [
          Hashie::Mash.new(
            type: block_type,
            has_children: has_children,
            id: 11
          ),
          Hashie::Mash.new(
            type: block_type,
            has_children: has_children,
            id: 11
          )
        ]
      )
    end
    let(:block_type) { 'dummy_type' }
    let(:has_children) { false }

    it 'returns a list of NotionToMd::Blocks::Block' do
      output = described_class.build(block_id: 'dummy_id') { page_notion }
      expect(output).to all(be_an(NotionToMd::Blocks::Block))
    end

    it 'returned list with no children' do
      output = described_class.build(block_id: 'dummy_id') { page_notion }
      expect(output).to include(an_object_having_attributes(children: []))
    end

    context('with blocks permitted to have children') do
      let(:block_type) { 'bulleted_list_item' }
      let(:has_children) { true }
      let(:block_nested_notion) do
        Hashie::Mash.new(
          type: block_type,
          has_children: true,
          id: 11,
          results: [
            Hashie::Mash.new(
              type: block_type,
              has_children: false,
              id: 111
            ),
            Hashie::Mash.new(
              type: block_type,
              has_children: false,
              id: 111
            )
          ]
        )
      end

      it 'returns a list with children' do
        output = described_class.build(block_id: 1) do |nested_block_id|
          case nested_block_id
          when 1
            page_notion
          when 11
            block_nested_notion
          end
        end

        expect(output).to include(an_object_having_attributes(
                                    children: include(a_kind_of(NotionToMd::Blocks::Block))
                                  ))
      end

      context('with children permitted to have children') do
        let(:block_nested_notion) do
          Hashie::Mash.new(
            type: block_type,
            has_children: true,
            id: 11,
            results: [
              Hashie::Mash.new(
                type: block_type,
                has_children: true,
                id: 111
              ),
              Hashie::Mash.new(
                type: block_type,
                has_children: true,
                id: 111
              )
            ]
          )
        end
        let(:block_2dn_nested_notion) do
          Hashie::Mash.new(
            type: block_type,
            has_children: true,
            id: 111,
            results: [
              Hashie::Mash.new(
                type: 'dummy_type',
                has_children: false,
                id: 1111
              ),
              Hashie::Mash.new(
                type: 'dummy_type',
                has_children: false,
                id: 1111
              )
            ]
          )
        end

        it 'returns a list with children' do
          output = described_class.build(block_id: 1) do |nested_block_id|
            case nested_block_id
            when 1
              page_notion
            when 11
              block_nested_notion
            when 111
              block_2dn_nested_notion
            end
          end

          expect(output).to include(
            an_object_having_attributes(
              children: include(
                an_object_having_attributes(
                  children: include(
                    a_kind_of(NotionToMd::Blocks::Block)
                  )
                )
              )
            )
          )
        end
      end
    end
  end
end
