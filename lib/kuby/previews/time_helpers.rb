module Kuby
  module Previews
    module TimeHelpers
      def every(num)
        Interval.new(num)
      end

      def exactly(num)
        Timespan.new(num)
      end
    end
  end
end