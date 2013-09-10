module NewRelic
  module Binding
    class Config
      def self.endpoint=(url)
        @endpoint = url
        if self.use_ssl? and !self.ssl_supported?
          Logger.warn('Using SSL is not recommended when using Ruby versions below 1.9')
        end
      end

      def self.use_ssl?
        @endpoint.start_with?('https')
      end

      def self.ssl_supported?
        !(!defined?(RUBY_ENGINE) || (RUBY_ENGINE == 'ruby' && RUBY_VERSION < '1.9.0'))
      end

      def self.skip_ssl_host_verification?
        !@ssl_host_verification
      end

      if self.ssl_supported?
        @endpoint = 'https://platform-api.newrelic.com'
      else
        @endpoint = 'http://platform-api.newrelic.com'
        Logger.warn('SSL is disabled by default when using Ruby 1.8.x')
      end
      @uri = '/platform/v1/metrics'
      @ssl_host_verification = true
      @poll_cycle_period = 60
      @proxy = nil
      class << self
        attr_accessor :ssl_host_verification, :uri, :poll_cycle_period, :proxy
        attr_reader :endpoint
      end
    end
  end
end
