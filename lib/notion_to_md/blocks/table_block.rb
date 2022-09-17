# frozen_string_literal: true

module NotionToMd
  module Blocks
    class TableBlock < Block
      def to_md
        markdownify_children(0).join("\n")
      end
    end
  end
end
