source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'faraday', '~> 2.4'
gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '~> 7.0.3'
gem 'uk_postcode'

gem 'govuk_design_system_formbuilder', '~> 3.1.0'

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

# Temporary utitily to add a data api to apply.
gem 'laa_crime_apply_dev_api', github: 'ministryofjustice/laa-crime-apply-dev-api',
ref: '506d72ced64e96ee3e82369ef73b95e56bfa72e8'

gem 'laa-criminal-applications-datastore-api-client',
    github: 'ministryofjustice/laa-criminal-applications-datastore-api-client'

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
  gem 'webdrivers'
  gem 'webmock'
end
