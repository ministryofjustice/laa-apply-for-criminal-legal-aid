ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require 'vcr'
SimpleCov.minimum_coverage 100

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:key)],
  }
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<BC_LSC_SERVICE_NAME>') { ENV.fetch('BC_LSC_SERVICE_NAME', nil) }
  config.filter_sensitive_data('<BC_CLIENT_ORG_ID>') { ENV.fetch('BC_CLIENT_ORG_ID', nil) }
  config.filter_sensitive_data('<BC_CLIENT_USER_ID>') { ENV.fetch('BC_CLIENT_USER_ID', nil) }
end

SimpleCov.start 'rails' do
  add_filter 'app/mailers/application_mailer.rb'
  add_filter 'app/jobs/application_job.rb'
  add_filter 'config/initializers'
  add_filter 'config/routes.rb'
  add_filter 'lib/rubocop/'
  add_filter 'spec/'
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
