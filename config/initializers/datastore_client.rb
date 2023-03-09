require 'datastore_api'

DatastoreApi.configure do |config|
  config.api_root = ENV.fetch('DATASTORE_API_ROOT', nil)
  config.api_path = '/api/v2'

  config.auth_type = :jwt

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::WARN
end
