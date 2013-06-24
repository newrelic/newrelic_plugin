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
        Time.iso8601(Time.now.utc.iso8601).to_s
      end
    end
  end
end
