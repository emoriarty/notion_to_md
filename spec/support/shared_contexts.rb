# frozen_string_literal: true

RSpec.shared_examples 'a callable interface' do
  describe '.call' do
    it 'returns the described class object' do
      expect(subject).to be_a(described_class)
    end
  end

  describe '.build' do
    it 'is an alias of .call' do
      expect(described_class.method(:build)).to eq(described_class.method(:call))
    end
  end
end
