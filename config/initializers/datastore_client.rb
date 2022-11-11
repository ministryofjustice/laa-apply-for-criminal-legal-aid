require 'datastore_api'

DatastoreApi.configure do |config|
  config.api_root = ENV.fetch('DATASTORE_API_ROOT', nil)

  # Basic auth is only needed on staging
  config.basic_auth_username = ENV.fetch('DATASTORE_AUTH_USERNAME', nil)
  config.basic_auth_password = ENV.fetch('DATASTORE_AUTH_PASSWORD', nil)
end
