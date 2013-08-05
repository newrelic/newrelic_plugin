module NewRelic
  module Binding
    class Context
      attr_reader :components, :version, :host, :pid, :license_key

      def initialize(version, host, pid, license_key)
        @version = version
        @host = host
        @pid = pid
        @license_key = license_key
        @components = []
      end

      def create_component(name, guid)
        component = Component.new(name, guid)
        @components.push(component)
        return component
      end

      def new_request(duration = nil)
        return Request.new(self, duration)
      end

    end
  end
end

