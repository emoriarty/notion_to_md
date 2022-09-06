# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Block::Block) do
  describe('to_md') do
    let(:block_value) { 'dummy text' }
    let(:block_mash) do
      Hashie::Mash.new(
        type: 'dummy_type'
      )
    end

    before do
      stub_const(
        'NotionToMd::Block::Types',
        instance_double('Types', dummy_type: block_value)
      )
    end

    context('with no children') do
      let(:block_children) { [] }

      it 'returns the markdown string' do
        block = described_class.new(block: block_mash, children: block_children)

        expect(block.to_md).to eq(block_value)
      end
    end

    context('with one children') do
      let(:block_children) do
        [described_class.new(block: Hashie::Mash.new(
          type: 'dummy_type'
        ))]
      end

      it 'returns the markdown string with nested child indented' do
        block = described_class.new(block: block_mash, children: block_children)

        expect(block.to_md).to eq("#{block_value}\n\n\t#{block_value}")
      end
    end

    context('with two children') do
      let(:block_children) do
        [described_class.new(
          block: Hashie::Mash.new(type: 'dummy_type')
        ),
         described_class.new(
           block: Hashie::Mash.new(type: 'dummy_type')
         )]
      end

      it 'returns the markdown string with nested child indented' do
        block = described_class.new(block: block_mash, children: block_children)
        expected_output = "#{block_value}\n\n\t#{block_value}\n\n\t#{block_value}"

        expect(block.to_md).to eq(expected_output)
      end
    end

    context('with one children with one nested children') do
      let(:block_children) do
        [described_class.new(
          block: Hashie::Mash.new(type: 'dummy_type'),
          children: [
            described_class.new(
              block: Hashie::Mash.new(type: 'dummy_type')
            )
          ]
        )]
      end

      it 'returns the markdown string with nested child indented' do
        block = described_class.new(block: block_mash, children: block_children)
        expected_output = "#{block_value}\n\n\t#{block_value}\n\n\t\t#{block_value}"

        expect(block.to_md).to eq(expected_output)
      end
    end

    context('with two children with one nested children') do
      let(:block_children) do
        [described_class.new(
          block: Hashie::Mash.new(type: 'dummy_type'),
          children: [
            described_class.new(
              block: Hashie::Mash.new(type: 'dummy_type')
            )
          ]
        ),
         described_class.new(
           block: Hashie::Mash.new(type: 'dummy_type'),
           children: [
             described_class.new(
               block: Hashie::Mash.new(type: 'dummy_type')
             )
           ]
         )]
      end

      it 'returns the markdown string with nested child indented' do
        block = described_class.new(block: block_mash, children: block_children)
        expected_output = "#{block_value}\n\n\t#{block_value}\n\n\t\t#{block_value}\n\n\t#{block_value}\n\n\t\t#{block_value}"

        expect(block.to_md).to eq(expected_output)
      end
    end
  end
end
