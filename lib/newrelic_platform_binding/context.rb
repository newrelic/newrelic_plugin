module NewRelic
  module Binding
    class Context
      AGGREGATION_LIMIT = 20
      attr_reader :components, :license_key
      attr_accessor :version, :host, :pid

      def initialize(license_key)
        @version = nil
        @host = nil
        @request = Request.new(self)
        @pid = nil
        @license_key = license_key
        @components = []
        @aggregation_start = Time.now
      end

      def create_component(name, guid)
        component = Component.new(name, guid)
        @components.push(component)
        return component
      end

      def get_component(name, guid)
        component = find_component(name, guid)
        component = create_component(name, guid) if component.nil?
        component
      end

      def find_component(name, guid)
        @components.find { |c| c.key == name + guid } unless @components.empty?
      end

      def get_request()
        if past_aggregation_limit?
          @components.each do |component|
            component.last_delivered_at = nil
          end
          @request = Request.new(self)
        elsif @request.delivered?
          @request = Request.new(self)
        else
          @request
        end
      end

      def last_request_delivered_at=(delivered_at)
        @aggregation_start = delivered_at
      end

    private
      def past_aggregation_limit?
        @aggregation_start < Time.now - AGGREGATION_LIMIT * 60
      end

    end
  end
end

