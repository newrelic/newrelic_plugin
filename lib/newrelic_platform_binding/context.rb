module NewRelic
  module Binding
    class Context
      attr_reader :components, :version, :host, :pid, :license_key

      def initialize(version, host, pid, license_key)
        @version = version
        @host = host
        @request = Request.new(self)
        @pid = pid
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

