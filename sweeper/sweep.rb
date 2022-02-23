$:.push(__dir__)
STDOUT.sync = true

require 'k8s-ruby'
require 'config'

ANNOTATION_KEY = :'getkuby.io/previews.expirationTimestamp'
TIMESTAMP_FORMAT = '%Y%m%d%H%M%S'.freeze
TIMESTAMP_TZ_FORMAT = '%Y%m%d%H%M%S%z'.freeze

def human_readable_timespan(seconds)
  result = seconds
  return "#{result.round}s" if result < 60

  result /= 60
  return "#{result.round}m" if result < 60

  result /= 60
  return "#{result.round}h" if result < 24

  result /= 24
  "#{result.round}d"
end

config = Config.load
client = K8s::Client.in_cluster_config

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

  now = Time.now.utc

  if exp_time <= now
    puts "Deleting expired namespace/#{ns.metadata.name}"

    begin
      client.api('v1').resource('namespaces').delete_resource(ns)
      puts "Successfully deleted expired namespace/#{ns.metadata.name}"
    rescue => e
      puts "Could not delete expired namespace/#{ns.metadata.name}: #{e.message}"
    end
  else
    remaining = exp_time - now
    puts "namespace/#{ns.metadata.name} has not yet expired, #{human_readable_timespan(remaining)} remaining"
  end
end
