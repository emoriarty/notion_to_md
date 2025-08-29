# frozen_string_literal: true

class NotionToMd
  # === NotionToMd::Database
  #
  # This class represents Notion Database object.
  class Database
    extend Forwardable

    class << self
      def call(database_id:, notion_client:, filter: nil, sorts: nil)
        metadata = notion_client.database(database_id: database_id)
        pages = Builder.call(database_id: database_id, notion_client: notion_client, filter: filter, sorts: sorts)

        new(metadata: metadata, pages: pages)
      end

      alias build call
    end

    attr_reader :metadata, :pages

    def_delegators :@metadata, :properties

    def initialize(metadata:, pages:)
      @metadata = metadata
      @pages = pages
    end
  end
end
