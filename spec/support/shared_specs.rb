# frozen_string_literal: true

RSpec.shared_examples 'metadata container' do
  let(:database_or_page) { described_class.new(metadata: metadata, children: children) }
  let(:metadata) { nil }
  let(:children) { nil }

  describe('#icon') do
    context('when is an emoji') do
      let(:emoji) { '\U0001F4A5' }
      let(:metadata) do
        {
          icon: {
            type: 'emoji',
            emoji: emoji
          }
        }
      end

      it { expect(database_or_page.icon).to be(emoji) }
    end

    context('when is an external file') do
      let(:url) { 'https://s3.us-west-2.amazonaws.com/secure.notion-static.com/X3f70b1X-2331-4012-99bc-24gcbd1c85sb/test.jpeg' }
      let(:metadata) do
        {
          icon: {
            type: 'external',
            external: {
              url: url,
              expiry_time: '2022-07-30T10:12:33.218Z'
            }
          }
        }
      end

      it { expect(database_or_page.icon).to be(url) }
    end
  end

  describe('#title') do
    let(:title) { 'Dummy title' }

    context('when the title is in the Name property') do
      let(:metadata) do
        {
          properties: {
            Name: {
              type: 'title',
              title: [
                { plain_text: title }
              ]
            }
          }
        }
      end

      it { expect(database_or_page.title).to eq(title) }
    end

    context('when the title is in the title property') do
      let(:metadata) do
        {
          properties: {
            title: {
              type: 'text',
              title: [
                { plain_text: title }
              ]
            }
          }
        }
      end

      it { expect(database_or_page.title).to eq(title) }
    end
  end
end
