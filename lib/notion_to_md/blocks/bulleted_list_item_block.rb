# frozen_string_literal: true

module NotionToMd
  module Blocks
    class BulletedListItemBlock < Block
      def newline
        "\n"
      end
    end
  end
end

