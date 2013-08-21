module NewRelic
  module Binding
    class Context
      attr_reader :components, :license_key
      attr_accessor :version, :host, :pid

      def initialize(license_key)
        @version = nil
        @host = nil
        @request = Request.new(self)
        @pid = nil
        @license_key = license_key
        @components = []
      end

      def create_component(name, guid)
        component = Component.new(name, guid)
        @components.push(component)
        return component
      end

      def get_request()
        if @request.delivered?
          @request = Request.new(self)
        end
        @request
      end

    end
  end
end

