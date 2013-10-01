module NewRelic
  require 'time'
  require 'logger'

  class PlatformLogger
    @log = ::Logger.new(STDOUT)
    @log.level = ::Logger::WARN
    @log.formatter = proc { |severity, datetime, progname, msg| "[#{Time.iso8601(Time.now.utc.iso8601).to_s}] #{severity}: #{msg}\n" }
    class << self
      def log_level=(level)
        @log.level = level
      end

      def fatal(message)
        @log.fatal(message)
      end

      def error(message)
        @log.error(message)
      end

      def warn(message)
        @log.warn(message)
      end

      def info(message)
        @log.info(message)
      end

      def debug(message)
        @log.debug(message)
      end

      def log_metrics=(value)
        @log_metrics = value
      end

    end
  end
end
