module NewRelic
  module Binding
    class Config
      @endpoint = 'https://platform-api.newrelic.com'
      @uri = '/platform/v1/metrics'
      @ssl_host_verification = true
      @poll_cycle_period = 60
      @proxy = nil
      class << self
        attr_accessor :endpoint, :ssl_host_verification, :uri, :poll_cycle_period, :proxy
      end
    end
  end
end
