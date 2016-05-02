# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.3.0'

# Declare your gem's dependencies in monarchy.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

group :development, :test do
  gem 'sqlite3'
  gem 'rubocop'
  gem 'pry-rails', '0.3.4'
  gem 'shoulda-matchers'
  gem 'rspec-rails'
  gem 'factory_girl_rails', '4.5.0'
  gem 'ffaker', '2.1.0'
  gem 'database_cleaner', '1.4.1'
end

gem 'simplecov', require: false, group: :test
