source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'faraday', '~> 2.7'
gem 'govuk_design_system_formbuilder', '~> 3.1.0'
gem 'jbuilder', '~> 2.11.5'
gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '~> 7.0.3'
gem 'uk_postcode'

# Authentication
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml', '~> 2.1.0'
gem 'warden'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'dartsass-rails', '~> 0.4.0'

# Exceptions notifications
gem 'sentry-rails'
gem 'sentry-ruby'

gem 'hmcts_common_platform', github: 'ministryofjustice/hmcts_common_platform', tag: 'v0.2.0'

gem 'laa-criminal-applications-datastore-api-client',
    github: 'ministryofjustice/laa-criminal-applications-datastore-api-client'

gem 'laa-criminal-legal-aid-schemas',
    github: 'ministryofjustice/laa-criminal-legal-aid-schemas'

gem 'kaminari'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'pry'
  gem 'rspec-rails'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'erb_lint', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'warden-rspec-rails' # if we move to Devise, we don't need this
  gem 'webdrivers'
  gem 'webmock'
end
