require 'datastore_api'

DatastoreApi.configure do |config|
  config.api_root = ENV.fetch('DATASTORE_API_ROOT', nil)
  config.api_path = ENV.fetch('DATASTORE_API_PATH', '/api/v1')

  # Basic auth is only needed on staging
  config.basic_auth_username = ENV.fetch('DATASTORE_AUTH_USERNAME', nil)
  config.basic_auth_password = ENV.fetch('DATASTORE_AUTH_PASSWORD', nil)

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::WARN
end
