require 'json'

module NewRelic
  module Plugin
#
# NewRelic driver. Provides all methods necessary for accessing the NewRelic service.
# Used to store data into NewRelic service.
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
#   msg.send_metrics # Send the list of stats to New Relic
#



    class NewRelicMessage
      #
      #
      # Create an object to send metrics
      #
      #
      def initialize connection,component_name,component_guid,component_version,duration_in_seconds
        @connection = connection
        @component_name = component_name
        @component_guid = component_guid
        @component_version = component_version
        @duration_in_seconds = duration_in_seconds
        @metrics = [] # Metrics being saved
      end
      def add_stat_fullname metric_name,count,value,opts={}
        entry = {}
        entry[:metric_name] = metric_name
        entry[:count] = count
        entry[:total] = value
        [:min,:max,:sum_of_squares].each do |key|
          entry[key] = opts[key]
        end
        @metrics << entry
      end

      def metrics
        @metrics
      end

      def send_metrics
        return_errors = []
        puts "Metrics for #{@component_name}[#{@component_guid}] for last #{@duration_in_seconds} seconds:" if new_relic_connection.log_metrics?
        #
        # Send all metrics in a single transaction
        #
        response = deliver_metrics
        evaluate_response(response)
        log_send_metrics
      end

      private

      def build_metrics_hash
        metrics_hash = {}
        metrics.each do |metric|
          metric_value = []
          [:total,:count,:max,:min,:sum_of_squares].each do |key|
            metric_value.push(metric[key]) if metric[key]
          end
          metrics_hash[metric[:metric_name]] = metric_value
        end
        return metrics_hash
      end
      
      def build_request_payload
        data = {
          "agent" => {
              "name" => @component_name,
              "version" => @component_version,
              "host" => ""
          },
          "components" => [
              {
                "name" => @component_name,
                "guid" => @component_guid,
                "duration" => @duration_in_seconds,
                "metrics" => build_metrics_hash
              } 
          ]
        }
        return data.to_json
      end

      def deliver_metrics
        begin
          response = new_relic_connection.connect.post do |req|
            req.url "/platform/v1/metrics"
            req.headers['Content-Type'] = 'application/json'
            req.body = build_request_payload
          end
        rescue => err
          puts "HTTP Connection Error: #{err.inspect} #{err.message}"
        end

        return response
      end

      def evaluate_response(response)
        return_status = nil
        if response.nil?
          last_result={"error" => "no response"}
          return_status = "FAILED: No response"
        elsif response && response.status == 200
          last_result = JSON.parse(response.body)
          if last_result["status"] != "ok"
            return_status = "FAILED[#{response.status}] <#{new_relic_connection.url}>: #{last_result["error"]}"
          end
        else
          begin
            if response.body.size>0
              last_result = JSON.parse(response.body)
            else
              last_result = {"error" => "no data returned"}
            end
            return_status = "FAILED[#{response.status}] <#{new_relic_connection.url}>: #{last_result["error"]}"
          rescue => err
            if response
              return_status = "FAILED[#{response.status}] <#{new_relic_connection.url}>: Could not parse response: #{err}"
            else
              return_status = "FAILED: #{err}"
            end
          end
        end
        if return_status
          puts "  ****ERROR: #{return_status}" if new_relic_connection.log_metrics?
        end
      end 

      def log_send_metrics
        if new_relic_connection.log_metrics?
          puts "  Sent #{metrics.size} metrics to New Relic [#{new_relic_connection.url}]:"
          metrics.each do |metric|
            val_strs = []
            [:count,:total,:min,:max,:sum_of_squares].each do |key|
              val_strs << "#{key}: #{metric[key]}" if metric[key]
            end
            puts "    #{metric[:metric_name]}: #{val_strs.join(', ')}"
          end
        end
      end

      def new_relic_connection
        @connection
      end
    end
  end
end
