$:.push(__dir__)
STDOUT.sync = true

require 'k8s-ruby'
require 'config'

ANNOTATION_KEY = :'io.getkuby/previews.expirationTimestamp'
TIMESTAMP_FORMAT = '%Y%m%d%H%M%S'.freeze
TIMESTAMP_TZ_FORMAT = '%Y%m%d%H%M%S%z'.freeze

config = Config.load
client = K8s::Client.in_cluster_config
# client = K8s::Client.config(
#   K8s::Config.load_file(
#     File.expand_path '~/.kube/config'
#   )
# )

namespaces = client.api('v1').resource('namespaces').list
namespaces.each do |ns|
  next if ns.metadata.name.start_with?('kube-')
  next unless ns.metadata.name.start_with?(config.namespace_prefix)

  puts "Examining namespace/#{ns.metadata.name}"

  annotations = (ns.metadata.annotations || {}).to_h
  expiration = annotations[ANNOTATION_KEY]

  unless expiration
    puts "namespace/#{ns.metadata.name} doesn't have an expiration annotation, skipping"
    next
  end

  exp_time = begin
    Time.strptime("#{expiration}+0000", TIMESTAMP_TZ_FORMAT)
  rescue ArgumentError
    puts "namespace/#{ns.metadata.name} had an invalid expiration annotation"
    next
  end

  if exp_time <= Time.now.utc
    puts "Deleting expired namespace/#{ns.metadata.name}"

    begin
      client.api('v1').resource('namespaces').delete_resource(ns)
      puts "Successfully deleted expired namespace/#{ns.metadata.name}"
    rescue => e
      puts "Could not delete expired namespace/#{ns.metadata.name}: #{e.message}"
    end
  end
end
