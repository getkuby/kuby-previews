STDOUT.sync = true

require File.expand_path('../../lib/kuby/previews/version', __dir__)

cmd = "docker push ghcr.io/getkuby/kuby-previews-sweeper:v#{Kuby::Previews::VERSION}"
puts cmd
exec cmd
