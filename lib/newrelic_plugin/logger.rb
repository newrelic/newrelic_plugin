module NewRelic
  module Plugin
    require 'time'

    class Logger
      def self.write(message)
        puts "[#{Logger.timestamp}] #{message}"
      end

      def self.timestamp
        Time.now.utc.iso8601
      end
    end
  end
end