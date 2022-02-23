require 'kube-dsl'
require 'digest'

module Kuby
  module Previews
    class PreviewConfig
      extend ::KubeDSL::ValueFields

      include TimeHelpers
      extend TimeHelpers

      value_field :ttl, default: exactly(5).days
      value_field :sweep_interval, default: every(1).hour
    end
  end
end
