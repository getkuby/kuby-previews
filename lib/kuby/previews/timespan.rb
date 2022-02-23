module Kuby
  module Previews
    class Timespan
      attr_reader :value
      alias_method :seconds, :value

      def initialize(value)
        @value = value
      end

      def minutes
        self.class.new(value * 60)
      end

      alias_method :minute, :minutes

      def hours
        self.class.new(value * 60 * 60)
      end

      alias_method :hour, :hours

      def days
        self.class.new(value * 24 * 60 * 60)
      end

      alias_method :day, :days

      def months
        self.class.new(value * 30 * 24 * 60 * 60)
      end

      alias_method :month, :months
    end
  end
end
