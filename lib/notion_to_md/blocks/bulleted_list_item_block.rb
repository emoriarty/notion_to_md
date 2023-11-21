# frozen_string_literal: true

module NotionToMd
  module Blocks
    class BulletedListItemBlock < Block
      def newline
        "\n"
      end

      def indent_children(mds, _tab_width)
        mds
      end
    end
  end
end
