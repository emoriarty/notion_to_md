# frozen_string_literal: true

require 'logger'

module NotionToMd
  class Logger
    @logger = ::Logger.new($stdout)

    class << self
      extend Forwardable
      def_delegators :@logger, :debug, :info, :warn, :error, :fatal
    end
  end
end
