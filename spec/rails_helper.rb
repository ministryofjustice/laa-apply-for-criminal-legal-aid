require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'

require 'laa_crime_schemas'

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = Rails.root.join('spec/fixtures')

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.include ActiveSupport::Testing::TimeHelpers

  config.include(FactoryHelpers)
  config.include(AuthenticationHelpers, type: :controller)
  config.include CapybaraHelpers, type: :system
  config.include CapybaraHelpers, type: :component

  config.include(ViewSpecHelpers, type: :helper)
  config.include(ViewSpecHelpers, type: :view)

  config.before(:each, type: :helper) { initialize_view_helpers(helper) }
  config.before(:each, type: :view) { initialize_view_helpers(view) }

  # As a default, we assume a user is signed in all controllers.
  # For specific scenarios, the user can be "signed off".
  config.before(:each, type: :controller) { sign_in }

  # Only request specs tagged with `authorized: true` will perform
  # an automatic sign in. Otherwise assume user is signed out.
  config.before(:all, :authorized, type: :request) { post provider_saml_omniauth_callback_path }

  # Use the faster rack test by default for system specs
  config.before(:each, type: :system) { driven_by :rack_test }
end

RSpec::Matchers.define_negated_matcher :not_change, :change

Evidence::Ruleset::Runner.load_rules!
