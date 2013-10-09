require 'set'
module NewRelic
  module Binding
    class Metric
      attr_reader :component, :name, :value, :count, :min, :max, :sum_of_squares

      def initialize(component, name, input_value, options = {} )
        value = input_value.to_f
        @component = component
        @name = name
        @value = value
        if options_has_required_keys(options)
          @count = options[:count].to_i
          @min = options[:min].to_f
          @max = options[:max].to_f
          @sum_of_squares = options[:sum_of_squares].to_f
        else
          PlatformLogger.warn("Metric #{@name} count, min, max, and sum_of_squares are all required if one is set, falling back to value only") unless options.size == 0
          @count = 1
          @min = value
          @max = value
          @sum_of_squares = (value * value)
        end
      end

      def aggregate(metric)
        @value += metric.value
        @count += metric.count
        @min = [@min, metric.min].min
        @max = [@max, metric.max].max
        @sum_of_squares += metric.sum_of_squares
      end

      def to_hash
        {
          name => [
            @value, @count, @min, @max, @sum_of_squares
          ]
        }
      end

      private

      def options_has_required_keys(options)
        options.keys.to_set.superset?(Set.new([:count, :min, :max, :sum_of_squares]))
      end
    end
  end
end
