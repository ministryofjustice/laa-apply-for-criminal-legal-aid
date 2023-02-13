require 'datastore_api'

DatastoreApi.configure do |config|
  config.api_root = ENV.fetch('DATASTORE_API_ROOT', nil)
  config.api_path = '/api/v2'

  # Basic auth is only needed on staging
  # To be replaced with `jwt` auth soon
  config.auth_type = :basic
  config.basic_auth_username = ENV.fetch('DATASTORE_AUTH_USERNAME', nil)
  config.basic_auth_password = ENV.fetch('DATASTORE_AUTH_PASSWORD', nil)

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::WARN
end
