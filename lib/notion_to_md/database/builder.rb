# frozen_string_literal: true

class NotionToMd
  class Database
    # === NotionToMd::Database::Builder
    #
    # This class is responsible for building the lists of pages that composes a database.
    class Builder
      class << self
        # === Parameters
        # database_id::
        #   A string representing a notion block or database id
        # notion_client::
        #   An Notion::Client object
        #
        # === Returns
        # An array of NotionToMd::Blocks::Block.
        #
        def call(database_id:, notion_client:)
          new(database_id: database_id, notion_client: notion_client).call
        end

        alias build call
      end

      attr_reader :database_id, :notion_client

      # === Parameters
      # database_id::
      #   A string representing a notion block id .
      # notion_client::
      #   An Notion::Client object
      #
      def initialize(database_id:, notion_client:)
        @database_id = database_id
        @notion_client = notion_client
      end

      # === Parameters
      #
      # === Returns
      # An array of NotionToMd::Page
      #
      def call
        fetch_pages.map do |page|
          NotionToMd::Page.call(page_id: page.id, notion_client: notion_client)
        end
      end

      # === Parameters
      # database_id::
      #   A string representing a notion block id.
      #
      # === Returns
      # An array of Notion::Messages::Message.
      #
      def fetch_pages
        all_pages = []
        start_cursor = nil

        loop do
          params = { database_id: database_id }
          params[:start_cursor] = start_cursor if start_cursor

          resp = notion_client.database_query(params)

          all_pages.concat(resp.results)

          break unless resp.has_more && resp.next_cursor

          start_cursor = resp.next_cursor
        end

        all_pages
      end
    end
  end
end
