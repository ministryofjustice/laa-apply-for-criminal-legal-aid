RSpec.configure do |config|
  # Devise defines authentication helpers when routes load. Ensure they exist
  # before any example stubs current_provider, regardless of test order.
  config.before(:suite) { Rails.application.reload_routes! }

  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
end
