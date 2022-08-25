ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.minimum_coverage 100

SimpleCov.start 'rails' do
  add_filter 'config/initializers'
  add_filter 'config/routes.rb'
  add_filter 'spec/'
  add_filter 'app/mailers/application_mailer.rb'
  add_filter 'app/jobs/application_job.rb'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.profile_examples = true
end
