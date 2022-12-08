RSpec.configure do |config|
  config.before(:suite) do
    OmniAuth.configure do |omniauth_config|
      omniauth_config.logger = Rails.logger
    end
  end
end
