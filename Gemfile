source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'faraday', '~> 2.7'
gem 'govuk-components'
gem 'govuk_design_system_formbuilder'
gem 'jbuilder', '~> 2.13.0'
gem 'kaminari'
gem 'lograge'
gem 'logstash-event'
gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '7.2.2.1'
gem 'uk_postcode'

# Authentication
gem 'devise', '~> 4.8'
gem 'omniauth_openid_connect', '0.8.0'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml', '~> 2.1.3'

# Accessing soap apis
gem 'savon'

# Monitoring
gem 'prometheus_exporter'

gem 'marcel'

# Virus scan with ClamAV
gem 'clamby', '1.6.10', require: false

# Exceptions notifications
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'stackprof'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'laa-criminal-applications-datastore-api-client',
    github: 'ministryofjustice/laa-criminal-applications-datastore-api-client', tag: 'v1.2.1',
    require: 'datastore_api'

gem 'laa-criminal-legal-aid-schemas',
    github: 'ministryofjustice/laa-criminal-legal-aid-schemas',
    tag: 'v1.7.1'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'ostruct'
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
  gem 'webmock'
end

gem 'cssbundling-rails', '~> 1.4'

gem 'jsbundling-rails', '~> 1.3'

gem 'propshaft', '~> 1.1'

gem 'csv', '~> 3.3'
