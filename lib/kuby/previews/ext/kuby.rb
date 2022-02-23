require 'kuby'

module Kuby
  module Previews
    module KubyPatch
      def preview_environment(name)
        definition.preview_environment(name.to_s) || raise(
          UndefinedEnvironmentError, "couldn't find a Kuby preview environment named "\
          "'#{name}'"
        )
      end
    end
  end
end

module Kuby
  class << self
    prepend ::Kuby::Previews::KubyPatch
  end
end
