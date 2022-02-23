require 'kuby/previews/ext/kuby'
require 'kuby/previews/ext/definition'

require 'kuby/previews/plugin'

module Kuby
  module Previews
    autoload :Interval,              'kuby/previews/interval'
    autoload :PreviewConfig,         'kuby/previews/preview_config'
    autoload :PreviewEnvironment,    'kuby/previews/preview_environment'
    autoload :PreviewKubernetesSpec, 'kuby/previews/preview_kubernetes_spec'
    autoload :Sweeper,               'kuby/previews/sweeper'
    autoload :TimeHelpers,           'kuby/previews/time_helpers'
    autoload :Timespan,              'kuby/previews/timespan'
  end
end

Kuby.register_plugin(:previews, ::Kuby::Previews::Plugin)
