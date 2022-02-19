require 'yaml'

class Config
  def self.load(path = 'config.yml')
    Config.new(YAML.load_file(path))
  end

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def namespace_prefix
    data['namespace_prefix']
  end
end
