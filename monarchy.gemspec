# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monarchy/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'monarchy'
  s.version     = Monarchy::VERSION
  s.authors     = ['Exelord']
  s.email       = ['exelord@macsour.com']
  s.homepage    = 'https://github.com/Exelord/Monarchy'
  s.summary     = 'Hierarchical access management system with roles inheritance.'
  s.description = s.summary
  s.license     = 'MIT'

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.test_files = Dir['test/**/*']

  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless s.respond_to?(:metadata)
  s.metadata['allowed_push_host'] = 'https://rubygems.org'

  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.3'

  s.add_dependency 'activerecord', '>=4.2.7.1'
  s.add_dependency 'closure_tree', '6.6.0'
  s.add_dependency 'configurations', '2.2.2'
  s.add_dependency 'active_record_union', '1.3.0'
  s.add_dependency 'tqdm', '0.3.0'

  s.add_development_dependency 'bundler', '~> 1.12'
  s.add_development_dependency 'rake', '~> 12.3.1'
  s.add_development_dependency 'rspec', '3.7.0'
end
