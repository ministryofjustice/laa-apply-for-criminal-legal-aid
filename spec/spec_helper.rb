ENV['RAILS_ENV'] ||= 'test'

unless ENV['COVERAGE'] == 'false'
  require 'simplecov'

  SimpleCov.start 'rails' do
    minimum_coverage 100 unless ENV['CI_NODE_INDEX']

    skip 'app/mailers/application_mailer.rb'
    skip 'app/jobs/application_job.rb'
    skip 'config/initializers'
    skip 'config/routes.rb'
    skip 'lib/rubocop/'
    skip 'spec/'

    # Track all application files to ensure consistent coverage across parallel runs
    cover '{app,lib}/**/*.rb'

    # Support for parallel CI runs - each runner saves results with unique ID
    command_name "Job #{ENV['GITHUB_JOB']}-#{ENV['CI_NODE_INDEX']}" if ENV['GITHUB_JOB'] && ENV['CI_NODE_INDEX']

    if ENV['CI']
      formatter SimpleCov::Formatter::SimpleFormatter
    else
      formatter SimpleCov::Formatter::MultiFormatter.new([
                                                           SimpleCov::Formatter::SimpleFormatter,
                                                           SimpleCov::Formatter::HTMLFormatter
                                                         ])
    end
  end
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
