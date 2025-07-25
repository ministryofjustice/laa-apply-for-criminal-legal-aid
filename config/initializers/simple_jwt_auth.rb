require 'simple_jwt_auth'

# If DatastoreApi `auth_type` is set to `jwt` then this
# configuration will be used to generate the auth tokens
#
SimpleJwtAuth.configure do |config|
  config.issuer = ENV.fetch('DATASTORE_API_CONSUMER', 'crime-apply')

  config.secrets_config = {
    config.issuer => ENV.fetch('DATASTORE_API_AUTH_SECRET', nil)
  }
end
