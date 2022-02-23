require 'kube-dsl'

module Kuby
  module Previews
    class Sweeper
      IMAGE = 'ghcr.io/getkuby/kuby-previews-sweeper'.freeze
      NAMESPACE = 'kuby-previews'.freeze

      attr_reader :environment, :cluster_role

      def initialize(environment, cluster_role)
        @environment = environment
        @cluster_role = cluster_role
      end

      def resources
        @resources ||= [
          cron_job,
          config_map,
          cluster_role_binding,
          service_account
        ]
      end

      def cron_job
        context = self

        @cron_job ||= KubeDSL::DSL::Batch::V1beta1::CronJob.new do
          metadata do
            namespace NAMESPACE
            name "#{context.environment.name}-preview-sweeper"
          end

          spec do
            schedule context.environment.preview_config.sweep_interval.to_cron

            job_template do
              spec do
                template do
                  spec do
                    container(:sweeper) do
                      name 'sweeper'
                      image "#{IMAGE}:v#{Kuby::Previews::VERSION}"
                      image_pull_policy 'Always'

                      volume_mount do
                        name 'config'
                        mount_path '/usr/src/app/config'
                      end
                    end

                    volume(:config) do
                      name 'config'

                      config_map do
                        name context.config_map.metadata.name
                      end
                    end

                    service_account_name context.service_account.metadata.name
                    restart_policy 'Never'
                  end
                end
              end
            end
          end
        end
      end

      def config_map
        context = self

        @config_map ||= KubeDSL.config_map do
          metadata do
            name "#{context.environment.name}-preview-config"
            namespace NAMESPACE
          end

          data do
            add 'config.yml', YAML.dump({
              'namespace_prefix' => "#{context.environment.kubernetes.selector_app}-#{context.environment.name}"
            })
          end
        end
      end

      def cluster_role_binding
        context = self

        @cluster_role_binding ||= KubeDSL.cluster_role_binding do
          metadata do
            name "#{context.environment.name}-manage-namespaces"
          end

          subject do
            kind 'ServiceAccount'
            name context.service_account.metadata.name
            namespace context.namespace
          end

          role_ref do
            kind 'ClusterRole'
            name context.cluster_role.metadata.name
            api_group 'rbac.authorization.k8s.io'
          end
        end
      end

      def service_account
        context = self

        @service_account ||= KubeDSL.service_account do
          metadata do
            name "#{context.environment.name}-preview-sa"
            namespace NAMESPACE
          end
        end
      end

      def namespace
        environment.kubernetes.namespace.metadata.name
      end
    end
  end
end