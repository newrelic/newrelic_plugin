require 'faraday'

module NewRelic
  module Plugin
    class NewRelicConnection
      #
      # Allowed configuration Values:
      #   license_key [required] Specifies RPM account to store metrics in
      #   host [optional] override default production collector
      #   port [optional] override default production collector
      #   verbose [optional] log HTTP transactions to stdout
      #
      def initialize config = {}
        @config = config
      end
      #
      # Start creating a message containing a set of metrics to New Relic.
      #
      def start_message component_name,component_guid,component_version,duration_in_seconds
        NewRelic::Plugin::NewRelicMessage.new self,component_name,component_guid,component_version,duration_in_seconds
      end

      #################### Internal Only
      #
      # Create HTTP tunnel to New Relic
      #
      def connect
        @connect ||= Faraday.new(:url => url, :ssl => { :verify => ssl_host_verification } ) do |builder|
          builder.request  :url_encoded
          builder.response :logger if @config["log_http"].to_i>0
          builder.use AuthenticationMiddleware,license_key
          builder.adapter  :net_http
        end
      end
      def url
        @config["endpoint"] || "https://platform-api.newrelic.com"
      end
      def uri
        @config["uri"] || "/platform/v1/metrics"
      end
      def ssl_host_verification
        ssl_host_verification = @config["ssl_host_verification"]
        return true if ssl_host_verification.nil?
        !!ssl_host_verification
      end
      class AuthenticationMiddleware < Faraday::Middleware
        def initialize(app,apikey)
          super(app)
          @apikey = apikey
        end
        def call(env)
          unless env[:request_headers]['X-License-Key']
            env[:request_headers]['X-License-Key'] = @apikey
          end
          @app.call(env)
        end
      end
      def log_metrics?
        @config["verbose"] || @config["log_metrics"]
      end
      def license_key
        @config["license_key"]
      end

    end
  end
end
