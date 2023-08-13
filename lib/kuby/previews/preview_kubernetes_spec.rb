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
        @preview_name ||= begin
          name = ENV['KUBY_PREVIEW_NAME']

          if !name
            if $stdin.tty?
              loop do
                $stdout.write "Preview name for '#{Kuby.environment.name}' environment: "
                name = $stdin.gets.strip

                if name.empty?
                  $stdout.puts 'Please enter a valid preview name'
                else
                  break
                end
              end
            else
              Kuby.logger.fatal(<<~END)
                Expected the KUBY_PREVIEW_NAME environment variable to be set. Please try this
                command again with the variable set, eg:

                KUBY_PREVIEW_NAME=somename bundle exec kuby -e #{Kuby.environment.name} ...
              END

              exit 1
            end
          end

          name
        end
      end
    end
  end
end
