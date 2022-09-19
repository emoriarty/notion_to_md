# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::Factory) do
  describe('build') do
    context 'when using a common block' do
      let(:block_mash) do
        Hashie::Mash.new(
          type: 'dummy_type'
        )
      end

      it do
        output = described_class.build(block: block_mash)

        expect(output).to be_an_instance_of(NotionToMd::Blocks::Block)
      end
    end

    context 'when using a table block' do
      let(:block_mash) do
        Hashie::Mash.new(
          type: 'table'
        )
      end

      it do
        output = described_class.build(block: block_mash)

        expect(output).to be_an_instance_of(NotionToMd::Blocks::TableBlock)
      end
    end
  end
end