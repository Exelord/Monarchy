# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'treelify/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "treelify"
  s.version     = Treelify::VERSION
  s.authors     = ["Exelord"]
  s.email       = [""]
  s.homepage    = "https://github.com/Exelord/Treelify"
  s.summary     = "Hierarchical access management system with roles inheritance."
  s.description = "Hierarchical access management system with roles inheritance."
  s.license     = "MIT"

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.test_files = Dir["test/**/*"]

  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails', '~> 4.2', '>= 4.2.4'
  s.add_dependency "closure_tree", "6.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "bundler", "~> 1.10"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec"
end
