# frozen_string_literal: true

require 'logger'

module NotionToMarkdown
  class Logger
    @logger = ::Logger.new(STDOUT)

    class << self
      extend Forwardable
      def_delegators :@logger, :debug, :info, :warn, :error, :fatal
    end
  end
end


