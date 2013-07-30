module NewRelic
  module Binding
    class Metric
      attr_reader :component, :name, :value, :count, :min, :max, :sum_of_squares

      def initialize(component, name, value, options = {} )
        @component = component
        @name = name
        @value = value
        @count = options[:count] ? options[:count] : 1
        @min = options[:min] ? options[:min] : value
        @max = options[:max] ? options[:max] : value
        @sum_of_squares = options[:sum_of_squares] ? options[:sum_of_squares] : (value * value)
      end

      def to_hash
        {
          name => [
            @value, @count, @max, @min, @sum_of_squares
          ]
        }
      end

    end
  end
end
