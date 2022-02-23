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
              name "#{name}-#{spec.preview_name}"[0...63]
            end
          end
        end

        @namespace.instance_exec(&block) if block
        @namespace
      end

      def preview_name
        ENV['KUBY_PREVIEW_NAME']
      end
    end
  end
end
