source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '~>3.2.6'
gem 'mongoid', '~> 3.0.3'
gem 'doorkeeper', git: 'https://github.com/andreareginato/doorkeeper', branch: 'mongoid_v3'
gem 'mongoid-ancestry', '~> 0.3.0'
gem 'rabl'
gem 'draper'
gem 'yajl-ruby'
gem 'rails_config'
gem 'addressable'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'bundler'

group :development, :test do
  gem 'foreman'
  gem 'sqlite3'
  gem 'rspec-rails', '~> 2.6'
  gem 'shoulda'
  gem 'capybara'
  gem 'capybara-json'
  gem 'factory_girl_rails', require: false
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'spork', '~> 1.0rc'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'hashie'
  gem 'rails_best_practices'
  gem 'debugger'
end

group :test do
  gem 'webmock'
  gem 'growl'
  gem 'rb-fsevent'
  gem 'launchy'
end

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '~> 1.0.3'
end
