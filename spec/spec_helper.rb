require 'rubygems'
require 'spork'

# This code runs once when you run your test suite
Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'

  # Routes and app/ classes reload
  require 'rails/application'
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  Spork.trap_method(Rails::Application, :eager_load!)

  # Draper preload of models
  require 'draper'
  Spork.trap_class_method(Draper::System, :load_app_local_decorators)

  # Load railties
  require File.expand_path('../../config/environment', __FILE__)
  Rails.application.railties.all { |r| r.eager_load! }

  # General require
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'webmock/rspec'
  require 'draper/rspec_integration'
  require 'database_cleaner'

  # RSpec configuration
  RSpec.configure do |config|
    config.mock_with :rspec

    config.before(:suite) { DatabaseCleaner[:active_record].strategy = :transaction }
    config.before(:each)  { DatabaseCleaner[:active_record].clean }

    config.before(:suite) { DatabaseCleaner[:mongoid].strategy = :truncation }
    config.before(:each)  { DatabaseCleaner[:mongoid].clean }
  end
end

# This code runs each time you run your specs.
Spork.each_run do
  FactoryGirl.reload
  I18n.backend.reload!
  Dir[Rails.root.join('spec/support/**/*.rb')].each           {|f| require f}
  Dir[Rails.root.join('spec/requests/support/**/*.rb')].each  {|f| require f}
end
