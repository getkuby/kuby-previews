require 'kuby'

module Kuby
  module Previews
    class PreviewKubernetesSpec < ::Kuby::Kubernetes::Spec
      def namespace(&block)
        @namespace ||= begin
          spec = self

          super do
            metadata do
              # namespaces can only be max 63 characters long
              name "#{name}-#{spec.environment.preview_config.sanitized_name}"[0...63]
            end
          end
        end

        @namespace.instance_exec(&block) if block
        @namespace
      end
    end
  end
end
