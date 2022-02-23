require 'kuby'

module Kuby
  module Previews
    module DefinitionPatch
      def preview_environment(name, &block)
        name = name.to_s
        environments[name] ||= ::Kuby::Previews::PreviewEnvironment.new(name, self)
        environments[name].instance_eval(&block) if block_given?
        environments[name]
      end
    end
  end
end

module Kuby
  class Definition
    prepend ::Kuby::Previews::DefinitionPatch
  end
end
