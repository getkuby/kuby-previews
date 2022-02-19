require 'kuby'

module Kuby
  module Previews
    class PreviewKubernetesSpec < ::Kuby::Kubernetes::Spec
      def namespace
        spec = self

        super do
          metadata do
            # namespaces can only be max 63 characters long
            name "#{name}-#{spec.preview_name}"[0...63]
          end
        end
      end

      def preview_name
        ENV.fetch('KUBY_PREVIEW_NAME')
      end
    end
  end
end
