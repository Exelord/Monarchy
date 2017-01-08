# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.3.1'

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
  gem 'sqlite3', '1.3.13'
  gem 'rubocop', '0.46.0'
  gem 'pry-rails', '0.3.4'
  gem 'shoulda-matchers', '3.1.1'
  gem 'rspec-rails', '3.5.2'
  gem 'factory_girl_rails', '4.8.0'
  gem 'ffaker', '2.4.0'
  gem 'database_cleaner', '1.5.3'
  gem 'tqdm', '0.3.0'
  gem 'rails', '5.0.1'
end

gem 'simplecov', '0.12.0', group: :test
gem 'codeclimate-test-reporter', '1.0.4', group: :test
