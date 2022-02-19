require 'kuby'

module Kuby
  class << self
    def preview_environment(name)
      definition.preview_environment(name.to_s) || raise(
        UndefinedEnvironmentError, "couldn't find a Kuby preview environment named "\
        "'#{name}'"
      )
    end
  end
end
