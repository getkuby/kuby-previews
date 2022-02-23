require 'kuby'
require 'kube-dsl'

module Kuby
  module Previews
    class Plugin < ::Kuby::Plugin
      ANNOTATION_KEY = 'getkuby.io/previews.expirationTimestamp'.freeze
      TIMESTAMP_FORMAT = '%Y%m%d%H%M%S'.freeze

      def before_deploy(manifest)
        ns = manifest.find(:namespace, environment.kubernetes.namespace.metadata.name)
        expiration = Time.now.utc + environment.preview_config.ttl.seconds

        ns.metadata do
          annotations do
            add ANNOTATION_KEY, expiration.strftime(TIMESTAMP_FORMAT)
          end
        end
      end

      def resources
        @resources ||= [
          cluster_role,
          namespace,
          *sweepers.flat_map(&:resources)
        ]
      end

      def namespace
        @namespace ||= KubeDSL.namespace do
          metadata do
            name Sweeper::NAMESPACE
          end
        end
      end

      def cluster_role
        @cluster_role ||= KubeDSL.cluster_role do
          metadata do
            name 'kuby-previews-sweeper-manage-namespaces'
          end

          rule do
            # empty string means core API group
            api_groups [""]
            resources %w(namespaces)
            verbs %w(list delete)
          end
        end
      end

      def definition
        Kuby.definition
      end

      private

      def sweepers
        @sweepers ||= each_preview_env.map do |preview_env|
          Sweeper.new(preview_env, cluster_role)
        end
      end

      def each_preview_env
        return to_enum(__method__) unless block_given?

        definition.environments.each do |_, env|
          yield env if env.is_a?(PreviewEnvironment)
        end
      end
    end
  end
end
