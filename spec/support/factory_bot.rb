# frozen_string_literal: true
require 'database_cleaner'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.lint
  end
end
