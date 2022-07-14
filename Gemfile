source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'config'

gem 'pg', '~> 1.4'
gem 'puma'
gem 'rails', '~> 7.0.3'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'dartsass-rails', '~> 0.4.0'


group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webdrivers'
end
