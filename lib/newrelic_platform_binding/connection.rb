require 'json'
require 'uri'
require 'net/http'
require 'net/https'
require 'zlib'

module NewRelic
  module Binding
    class Connection
      attr_reader :license_key, :url

      def initialize(context)
        @url = Config.endpoint + Config.uri
        @license_key = context.license_key
      end

      def send_request(data)
        begin
          PlatformLogger.debug("JSON payload: #{data}")
          uri = URI.parse(url)
          if Config.proxy.nil?
            http = Net::HTTP.new(uri.host, uri.port)
          else
            proxy = Config.proxy
            http = Net::HTTP.new(uri.host, uri.port, proxy['address'], proxy['port'], proxy['user'], proxy['password'])
          end
          if Config.use_ssl?
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Config.skip_ssl_host_verification?
          end
          http.open_timeout = 20
          http.read_timeout = 20
          request = Net::HTTP::Post.new(uri.path)
          request['content-type'] = 'application/json'
          request['X-License-Key'] = @license_key
          request['Content-Encoding'] = 'deflate'
          request.body = Zlib::Deflate.deflate(data)
          response = http.request(request)
          return evaluate_response(response)
        rescue Timeout::Error => err
          PlatformLogger.warn "Connection Timeout Error: #{err.inspect} #{err.message}"
          return false
        rescue => err
          PlatformLogger.warn "HTTP Connection Error: #{err.inspect} #{err.message}"
          return false
        end
      end

    private
      def evaluate_response(response)
        return_status = nil
        begin
          if response.nil?
            last_result = { "error" => "no response" }
            return_status = "FAILED: No response"
          elsif response && response.code == '200'
            last_result = JSON.parse(response.body)
            if last_result["status"] != "ok"
              return_status = "FAILED[#{response.code}] <#{url}>: #{last_result["error"]}"
            end
          elsif response && response.code == '403' && response.body == "DISABLE_NEW_RELIC"
            PlatformLogger.fatal "Agent has been disabled remotely by New Relic"
            abort "Agent has been disabled remotely by New Relic"
          else
            if response.body.size > 0
              last_result = JSON.parse(response.body)
            else
              last_result = {"error" => "no data returned"}
            end
            return_status = "FAILED[#{response.code}] <#{url}>: #{last_result["error"]}"
          end
        rescue => err
          return_status = "FAILED[#{response.code}] <#{url}>: Could not parse response: #{err.message}"
        end
        if return_status
          if response and response.code == '503'
            PlatformLogger.warn("Collector temporarily unavailable. Continuing.")
          else
            PlatformLogger.error("#{return_status}")
          end
        end

        return_status.nil?
      end

    end
  end
end
