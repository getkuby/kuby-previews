require 'kuby'

module Kuby
  class Definition
    def preview_environment(name, &block)
      name = name.to_s
      preview_environments[name] ||= ::Kuby::Previews::PreviewEnvironment.new(name, self)
      preview_environments[name].instance_eval(&block) if block_given?
      preview_environments[name]
    end

    def preview_environments
      @preview_environments ||= {}
    end
  end
end
