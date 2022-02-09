# frozen_string_literal: true

module NotionToMd
  class Logger
    @logger = ::Logger.new($stdout)

    class << self
      extend Forwardable
      def_delegators :@logger, :debug, :info, :warn, :error, :fatal, :level, :level=
    end
  end
end
