# frozen_string_literal: true

module NotionToMd
  module Blocks
    class NumberedListBlock < BulletedListBlock
      def type
        'numbered_list'
      end
    end
  end
end
