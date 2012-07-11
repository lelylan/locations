require 'rubygems'
require 'spork'

# This code runs once when you run your test suite
Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'

  # Routes and app/ classes reload
  require 'rails/application'
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  Spork.trap_method(Rails::Application, :eager_load!)

  # Load railties
  require File.expand_path('../../config/environment', __FILE__)
  Rails.application.railties.all { |r| r.eager_load! }

  # General require
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'webmock/rspec'
  require 'draper/rspec_integration'
  require 'database_cleaner'

  RSpec.configure do |config|
    config.mock_with :rspec

    config.before(:suite) { DatabaseCleaner.strategy = :truncation }
    config.before(:each)  { DatabaseCleaner.clean }

    config.alias_it_should_behave_like_to :it_validates, "it validates"
    #config.infer_base_class_for_anonymous_controllers = false
  end
end


# This code runs each time you run your specs.
Spork.each_run do
  # Factory girl reload
  FactoryGirl.reload
  # I18n reload
  I18n.backend.reload!
  # Requires supporting ruby files with custom matchers and macros, etc.
  # Putting them in here we do load support file changes every time.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  Dir[Rails.root.join("spec/requests/support/**/*.rb")].each {|f| require f}
end
