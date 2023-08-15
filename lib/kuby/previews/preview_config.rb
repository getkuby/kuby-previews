require 'kube-dsl'
require 'digest'

module Kuby
  module Previews
    class MissingPreviewNameError < StandardError; end

    class PreviewConfig
      extend ::KubeDSL::ValueFields

      include TimeHelpers
      extend TimeHelpers

      value_field :name, default: -> do
        raise MissingPreviewNameError, 'missing preview name, please configure one'
      end

      value_field :ttl, default: exactly(5).days
      value_field :sweep_interval, default: every(1).hour

      def sanitized_name
        name.gsub(/[^\w.]/, '-').downcase
      end
    end
  end
end
