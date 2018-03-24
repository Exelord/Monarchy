# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.4.2'

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
  gem 'database_cleaner', '1.6.2'
  gem 'db-query-matchers', '0.9.0'
  gem 'factory_girl_rails', '4.9.0'
  gem 'ffaker', '2.8.1'
  gem 'pry-rails', '0.3.6'
  gem 'rails', '5.1.5'
  gem 'rspec-rails', '3.7.2'
  gem 'rubocop', '0.54.0'
  gem 'shoulda-matchers', '3.1.2'
  gem 'sqlite3', '1.3.13'
end

gem 'codeclimate-test-reporter', '~>1.0.8', group: :test
gem 'simplecov', '0.13.0', group: :test
