$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "treelify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "treelify"
  s.version     = Treelify::VERSION
  s.authors     = ["Exelord"]
  s.email       = [""]
  s.homepage    = "https://github.com/Exelord/Treelify"
  s.summary     = ""
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"
  s.add_dependency "closure_tree", "6.0.0"

  s.add_development_dependency "sqlite3"
end
