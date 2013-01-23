require 'faraday'
require 'json'

module NewRelic
  module Plugin
#
# NewRelic driver. Provides all methods necessary for accessing the NewRelic service.
# Used to store data into NewRelic service.
#
# Author:: Lee Atchison <lee@newrelic.com>
# Copyright:: Copyright (c) 2012 New Relic, Inc.
#
# Usage:
#
#   nrobj=NewRelic::Plugin::NewRelicConnection.new license_key:"xxx",host:"xxx",port:80,log_http:true,log_metrics:true # log_http,host and port are optional; license key is not.
#   msg=nrobj.start_message <component_name>,<component_guid>,<component_version>,<duration_in_seconds>
#   msg.add_stat basename,count_unit,value_unit,count,value,opts={} # opts can include :min, :max, and :sum_of_squares
#   msg.send_message # Send the list of stats to New Relic
#
# Example:
#   nrobj=NewRelic::Plugin::NewRelicConnection.new license_key:"bootstrap_newrelic_admin_license_key_000",host:"localhost",port:8081,log_http:true,log_metrics:true
#   msg=nrobj.start_message "A Kewl Component","12345678","0.0.1",60
#   msg.add_stat_fullname "Component/TestMetric1[Bytes/Seconds]",2,34,min:31,max:54,sum_of_squares:1234
#   msg.add_stat_fullname "Component/AnotherTest[Bytes/Seconds]",2,34,min:31,max:54,sum_of_squares:1234
#   msg.add_stat_fullname "Component/TestMetric2[Bytes/Seconds]",2,34,min:31,max:54,sum_of_squares:1234
#   msg.add_stat_fullname "Component/AnotherMetric[Bytes/Seconds]",2,34,min:31,max:54,sum_of_squares:1234
#   msg.send # Send the list of stats to New Relic
#
    class NewRelicConnection
      #
      # Allowed configuration Values:
      #   license_key [required] Specifies RPM account to store metrics in
      #   host [optional] override default production collector
      #   port [optional] override default production collector
      #   verbose [optional] log HTTP transactions to stdout
      #
      def initialize config={}
        @config=config
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
        @connect||=Faraday.new(:url => url) do |builder|
          builder.request  :url_encoded
          builder.response :logger if @config["log_http"].to_i>0
          builder.use AuthenticationMiddleware,license_key
          builder.adapter  :net_http
        end
      end
      def url
        host=@config["host"]||"collector.newrelic.com"
        port=@config["port"]||80
        "http://#{host}:#{port}"
      end
      class AuthenticationMiddleware < Faraday::Middleware
        def initialize(app,apikey)
          super(app)
          @apikey=apikey
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



    class NewRelicMessage
      #
      #
      # Create an object to send metrics
      #
      #
      def initialize connection,component_name,component_guid,component_version,duration_in_seconds
        @connection=connection
        @component_name=component_name
        @component_guid=component_guid
        @component_version=component_version
        @duration_in_seconds=duration_in_seconds
        @metrics=[] # Metrics being saved
      end
      def add_stat_fullname metric_name,count,value,opts={}
        entry={}
        entry[:metric_name]=metric_name
        entry[:count]=count
        entry[:total]=value
        [:min,:max,:sum_of_squares].each do |key|
          entry[key]=opts[key]
        end
        @metrics << entry
      end
      def send
        return_errors=[]
        puts "Metrics for #{@component_name}[#{@component_guid}] for last #{@duration_in_seconds} seconds:" if nr.log_metrics?
        bulkify(@metrics).each do |metric_group|
          #
          # Send all metrics in 'metrics' in a single transaction
          #
          begin
            #
            # Create the metrics hash
            #
            metrics={}
            metric_group.each do |metric|
              val={}
              [:count,:total,:min,:max,:sum_of_squares].each do |key|
                val[key]=metric[key] if metric[key]
              end
              metrics[metric[:metric_name]]=val
            end
            #
            # Send Post
            #
            response=nr.connect.post do |req|
              req.url "/api/v1/metrics"
              req.headers['Content-Type'] = 'application/json'
              data={
                  "description" => {
                      "name"=>@component_name,
                      "guid"=>@component_guid,
                      "type"=>"com.newrelic.newrelic_plugin",
                      "host"=>""
                  },
                  "duration" => @duration_in_seconds,
                  "metrics" => metrics
                }
              data["description"]["agent_version"] = @component_version if @component_version
              req.body = data.to_json
            end
          rescue =>err
            puts "HTTP Connection Error: #{err.inspect} #{err.message}"
          end
          return_status=nil
          if response.nil?
            last_result={"error" => "no response"}
            return_status="FAILED: No response"
          elsif response && response.status==200
            last_result=JSON.parse(response.body)
            if last_result["status"]!="ok"
              return_status="FAILED[#{response.status}] <#{nr.url}>: #{last_result["error"]}"
            end
          else
            begin
              if response.body.size>0
                last_result=JSON.parse(response.body)
              else
                last_result={"error" => "no data returned"}
              end
              return_status="FAILED[#{response.status}] <#{nr.url}>: #{last_result["error"]}"
            rescue => err
              if response
                return_status="FAILED[#{response.status}] <#{nr.url}>: Could not parse response: #{err}"
              else
                return_status="FAILED: #{err}"
              end
            end
          end
          if return_status
            return_errors << return_status
            puts "  ****ERROR: #{return_status}" if nr.log_metrics?
          end
          #
          # Log this
          #
          if nr.log_metrics?
            puts "  Sent #{metric_group.size} metrics to New Relic [#{nr.url}]:"
            metric_group.each do |metric|
              val_strs=[]
              [:count,:total,:min,:max,:sum_of_squares].each do |key|
                val_strs << "#{key}: #{metric[key]}" if metric[key]
              end
              puts "    #{metric[:metric_name]}: #{val_strs.join(', ')}"
            end
          end
        end
        return nil unless return_errors.size>0
        return_errors
      end
      #################### Private
      private
      #
      # Takes an array of metrics, and returns an array of arrays of metrics, with each
      # array of metrics small enough to fit in a single HTTP transaction
      #
      def bulkify metrics
        # Limit the uploads to 5000 metrics per request.  Consider throwing an error if there are more 
        # than this--the documented limit is 5000 but at this writing unenforced by the server.
        metrics.each_slice(5000).to_a
      end

      def nr
        @connection
      end
    end
  end
end
