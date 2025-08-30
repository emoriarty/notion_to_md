# frozen_string_literal: true

require 'forwardable'

class NotionToMd
  module Blocks
    # === NotionToMd::Blocks::Block
    #
    # Represents a Notion block and provides functionality
    # to convert it (and its children) into Markdown.
    #
    # A block corresponds to a `Notion::Messages::Message`
    # returned by the [notion-ruby-client](https://github.com/orbit-love/notion-ruby-client).
    #
    # @example Convert a block to Markdown
    #   block = NotionToMd::Blocks::Block.new(block: notion_message, children: [])
    #   puts block.to_md
    #
    # @see NotionToMd::Blocks::Renderer
    class Block
      extend Forwardable

      # @return [Notion::Messages::Message] The Notion API block data.
      attr_reader :block

      # @return [Array<NotionToMd::Blocks::Block>] The nested child blocks.
      attr_reader :children

      # Delegate the `#type` method to the underlying `block`.
      def_delegators :block, :type

      # Initialize a new block wrapper.
      #
      # @param block [Notion::Messages::Message]
      #   A Notion block message from the Notion API.
      # @param children [Array<NotionToMd::Blocks::Block>]
      #   Nested blocks belonging to this block.
      def initialize(block:, children: [])
        @block = block
        @children = children
      end

      # Convert the block (and its children) into Markdown.
      #
      # Uses {NotionToMd::Blocks::Renderer} to render
      # the Markdown representation of the block.
      #
      # @param tab_width [Integer] The number of tabs used to indent nested blocks. Defaults to 0.
      #
      # @return [String, nil] The Markdown string, or `nil` if the block type is unsupported.
      #
      # @see NotionToMd::Blocks::Renderer
      def to_md(tab_width: 0)
        block_type = block.type.to_sym
        md = Renderer.send(block_type, block[block_type]) + newline
        md + build_nested_blocks(tab_width + 1)
      rescue NoMethodError
        Logger.info("Unsupported block type: #{block_type}")
        nil
      end

      protected

      # @return [String] Two newlines separating blocks.
      def newline
        "\n\n"
      end

      # Build the Markdown for all nested blocks.
      #
      # @param tab_width [Integer] The indentation level.
      # @return [String]
      def build_nested_blocks(tab_width)
        mds = markdownify_children(tab_width).compact
        indent_children(mds, tab_width).join
      end

      # Render children blocks into Markdown.
      #
      # @param tab_width [Integer] The indentation level.
      # @return [Array<String, nil>] Markdown strings (or nil if unsupported).
      def markdownify_children(tab_width)
        children.map do |nested_block|
          nested_block.to_md(tab_width: tab_width)
        end
      end

      # Indent the Markdown output of children by `tab_width`.
      #
      # @param mds [Array<String>] Markdown strings.
      # @param tab_width [Integer] The indentation level.
      # @return [Array<String>] Indented Markdown strings.
      def indent_children(mds, tab_width)
        mds.map do |md|
          "#{"\t" * tab_width}#{md}"
        end
      end
    end
  end
end
