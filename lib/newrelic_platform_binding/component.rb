module NewRelic
  module Binding
    class Component
      attr_reader :name, :guid
      attr_accessor :last_delivered_at

      def initialize(name, guid)
        @name = name
        @guid = guid
        @last_delivered_at = nil
      end

      ##########################################################################
      # Methods below are not intended to be used as part of the public API
      ##########################################################################

      def key
        return (name + guid)
      end

      def duration
        if last_delivered_at.nil?
          return NewRelic::Binding::Config.poll_cycle_period
        else
          return (Time.now - last_delivered_at).ceil
        end
      end

    end
  end
end
