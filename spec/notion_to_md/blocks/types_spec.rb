# frozen_string_literal: true

require 'spec_helper'

describe(NotionToMd::Blocks::Types) do
  describe('.code') do
    context('when language is javascript') do
      let(:block_code) do
        {
          caption: [],
          language: 'javascript',
          rich_text: [{
            type: 'text',
            plain_text: 'function fn(a) {\n\treturn a;\n}',
            href: nil,
            text: {
              content: 'function fn(a) {\n\treturn a;\n}',
              link: nil
            },
            annotations: {
              bold: false,
              italic: false,
              strikethrough: false,
              underline: false,
              code: false,
              color: 'default'
            }
          }]
        }
      end

      it { expect(described_class.code(block_code)).to start_with('```javascript') }

      it do
        output = described_class.code(block_code)
        non_wrapped_output = output.lines[1..-2].join
        expect_output = "#{block_code[:rich_text][0][:plain_text]}\n"

        expect(non_wrapped_output).to eq(expect_output)
      end

      it { expect(described_class.code(block_code)).to end_with('```') }
    end

    context('when language is plain text') do
      let(:block_code) do
        {
          caption: [],
          language: 'plain text',
          rich_text: [{
            type: 'text',
            plain_text: 'This is a plain text',
            href: nil,
            text: {
              content: 'This is a plain text',
              link: nil
            },
            annotations: {
              bold: false,
              italic: false,
              strikethrough: false,
              underline: false,
              code: false,
              color: 'default'
            }
          }]
        }
      end

      it { expect(described_class.code(block_code)).to start_with('```text') }

      it do
        output = described_class.code(block_code)
        non_wrapped_output = output.lines[1..-2].join
        expect_output = "#{block_code[:rich_text][0][:plain_text]}\n"

        expect(non_wrapped_output).to eq(expect_output)
      end

      it { expect(described_class.code(block_code)).to end_with('```') }
    end
  end

  describe('.paragraph') do
    context('when rich_text is empty') do
      let(:block_paragraph) do
        {
          rich_text: []
        }
      end

      it { expect(described_class.paragraph(block_paragraph)).to eq('<br />') }
    end

    context('when rich_text is not empty') do
      let(:block_paragraph) do
        {
          rich_text: [{
            type: 'text',
            plain_text: 'This is a paragraph',
            href: nil,
            text: {
              content: 'This is a paragraph',
              link: nil
            },
            annotations: {
              bold: false,
              italic: false,
              strikethrough: false,
              underline: false,
              code: false,
              color: 'default'
            }
          }]
        }
      end

      it { expect(described_class.paragraph(block_paragraph)).to eq("#{block_paragraph[:rich_text][0][:plain_text]}") }
    end

    context('when rich_text is not empty and has a link') do
      let(:block_paragraph) do
        {
          rich_text: [{
            type: 'text',
            plain_text: 'This is a paragraph',
            href: 'https://www.google.com',
            text: {
              content: 'This is a paragraph',
              link: {
                url: 'https://www.google.com'
              }
            },
            annotations: {
              bold: false,
              italic: false,
              strikethrough: false,
              underline: false,
              code: false,
              color: 'default'
            }
          }]
        }
      end

      it { expect(described_class.paragraph(block_paragraph)).to eq("[#{block_paragraph[:rich_text][0][:plain_text]}](#{block_paragraph[:rich_text][0][:href]})") }
    end

    context('when rich_text is not empty and has a encoded link') do
      let(:block_paragraph) do
        {
          rich_text: [{
            type: 'text',
            plain_text: 'This is a paragraph',
            href: 'https://git.postgresql.org/gitweb/?p=postgresql.git%3Ba%3Dblob%3Bf%3Dsrc%2Fbin%2Finitdb%2Finitdb.c%3Bh%3Dc854221a30602c5a1e5abf73b0942b263859d715%3Bhb%3DHEAD#l3193',
            text: {
              content: 'This is a paragraph',
              link: {
                url: 'https://git.postgresql.org/gitweb/?p=postgresql.git%3Ba%3Dblob%3Bf%3Dsrc%2Fbin%2Finitdb%2Finitdb.c%3Bh%3Dc854221a30602c5a1e5abf73b0942b263859d715%3Bhb%3DHEAD#l3193'
              }
            },
            annotations: {
              bold: false,
              italic: false,
              strikethrough: false,
              underline: false,
              code: false,
              color: 'default'
            }
          }]
        }
      end

      it { expect(described_class.paragraph(block_paragraph)).to eq("[#{block_paragraph[:rich_text][0][:plain_text]}](https://git.postgresql.org/gitweb/?p=postgresql.git;a=blob;f=src/bin/initdb/initdb.c;h=c854221a30602c5a1e5abf73b0942b263859d715;hb=HEAD#l3193)") }
    end
  end

  describe('.link_preview') do
    context('when rich_text is present') do
      let(:block_link_preview) do
        {
          url: 'https://www.example.com',
        }
      end

      it { expect(described_class.link_preview(block_link_preview)).to eq("[#{block_link_preview[:url]}](#{block_link_preview[:url]})") }
    end
  end
end
