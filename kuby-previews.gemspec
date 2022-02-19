$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'kuby/previews/version'

Gem::Specification.new do |s|
  s.name     = 'kuby-previews'
  s.version  = ::Kuby::Previews::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/getkuby/kuby-previews'

  s.description = s.summary = 'Run copies of your application in ephemeral preview environments.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'kuby-core', '>= 0.17.0', '< 1.0'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'Gemfile', 'LICENSE', 'CHANGELOG.md', 'README.md', 'Rakefile', 'kuby-previews.gemspec']
end
