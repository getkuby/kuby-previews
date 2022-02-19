require 'kuby'

module Kuby
  module Previews
    class PreviewEnvironment < ::Kuby::Environment
      def configure_preview(&block)
        preview_config.instance_eval(&block) if block
      end

      def preview_config
        @preview_config ||= PreviewConfig.new
      end

      def kubernetes(&block)
        @kubernetes ||= PreviewKubernetesSpec.new(self)
        @kubernetes.instance_eval(&block) if block
        @kubernetes
      end
    end
  end
end
