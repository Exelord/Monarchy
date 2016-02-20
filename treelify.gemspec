$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "treelify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "treelify"
  s.version     = Treelify::VERSION
  s.authors     = ["Maciej Kwaśniak"]
  s.email       = ["kmaciek17@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Treelify."
  s.description = "TODO: Description of Treelify."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
end
