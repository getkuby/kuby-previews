module Kuby
  module Previews
    class Interval
      attr_reader :value, :units

      def initialize(value, units = :minutes)
        @value = value
        @units = units
      end

      def minutes
        self
      end

      alias_method :minute, :minutes

      def hours
        self.class.new(value, :hours)
      end

      alias_method :hour, :hours

      def days
        self.class.new(value, :days)
      end

      alias_method :day, :days

      def to_cron
        case units
          when :minutes
            value == 1 ? "* * * * *" : "*/#{value} * * * *"
          when :hours
            value == 1 ? "0 * * * *": "0 */#{value} * * *"
          when :days
            value == 1 ? "0 0 * * *": "0 0 */#{value} * *"
        end
      end
    end
  end
end
