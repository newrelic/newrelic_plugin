module NewRelic
  module Binding
    class Metric
      attr_reader :component, :name, :value, :count, :min, :max, :sum_of_squares

      def initialize(component, name, input_value, options = {} )
        value = input_value.to_f
        @component = component
        @name = name
        @value = value
        @count = options[:count] ? options[:count].to_f : 1
        @min = options[:min] ? options[:min].to_f : value
        @max = options[:max] ? options[:max].to_f : value
        @sum_of_squares = options[:sum_of_squares] ? options[:sum_of_squares].to_f : (value * value)
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
