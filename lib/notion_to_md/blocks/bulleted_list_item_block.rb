# frozen_string_literal: true

module NotionToMd
  module Blocks
    class BulletedListItemBlock < Block
      def newline
        @newline || "\n"
      end
    end
  end
end

