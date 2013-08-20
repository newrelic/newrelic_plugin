require 'json'
module NewRelic
  module Binding
    class Request
      attr_reader :context

      def initialize(context)
        @context = context
        @duration = nil
        @metrics = {}
        @delivered = false
        return self
      end

      def deliver
        metrics_hash = build_request_data_structure
        connection = Connection.new(@context)
        if connection.send_request(metrics_hash.to_json)
          @delivered = true
          delivered_at = Time.now
          duration_warning = false
          @context.components.each do |component|
            if @metrics.has_key?(component.key)
              duration_warning = true if component.duration > 600
              component.last_delivered_at = delivered_at
            end
          end
          Logger.warn("Duration of more than 10 minutes between sending data to New Relic, this will cause plugins to show up as not reporting") if duration_warning
        end
      end

      def add_metric(component, name, value, options = {})
        metric = find_metric(component, name)
        new_metric =  Metric.new(self, name, value, options)
        if metric.nil?
          metric = new_metric
          @metrics[component.key] ||= []
          @metrics[component.key].push(metric)
        else
          metric.aggregate(new_metric)
        end
        return metric
      end

      def metric_count
        count = 0
        @metrics.each do |m|
          count = count + m.size
        end
        count
      end

      def component_count
        @metrics.size
      end

      def delivered?
        @delivered
      end
    private
      def find_metric(component, name)
        @metrics[component.key].find { |m| m.name == name } unless @metrics[component.key].nil?
      end

      def build_request_data_structure
        {
          'agent' => build_agent_hash(),
          'components' => build_components_array()
        }
      end

      def build_agent_hash
        agent_hash = {
          'version' => @context.version,
        }
        agent_hash['host'] = @context.host unless @context.host.nil?
        agent_hash['pid'] = @context.pid unless @context.pid.nil?
        agent_hash
      end

      def build_components_array
        components_array = []
        @context.components.each do |component|
          component_hash = {
            'name' => component.name,
            'guid' => component.guid,
            'duration' => component.duration,
            'metrics' => build_metrics_hash(component)
          }
          components_array.push(component_hash)
        end
        return components_array
      end

      def build_metrics_hash(component)
        metrics_hash = {}
        if @metrics.has_key?(component.key)
          @metrics[component.key].each do |metric|
            metrics_hash.merge!(metric.to_hash)
          end
        else
          Logger.warn("Component with name \"#{component.name}\" and guid \"#{component.guid}\" had no metrics")
        end
        metrics_hash
      end

    end
  end
end

