module NewRelic
  module Plugin
    require 'time'

    class Logger
      def self.write(message)
        Logger.output "[#{Logger.timestamp}] #{message}"
      end

      def self.output(message)
        puts message
      end

      def self.timestamp
        Time.now.utc.iso8601
      end
    end
  end
end
