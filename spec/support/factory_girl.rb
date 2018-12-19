# frozen_string_literal: true

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.start
    FactoryGirl.lint
  ensure
    DatabaseCleaner.clean
  end
end
