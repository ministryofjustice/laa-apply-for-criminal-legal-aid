require 'json-schema'

# The schemas gem pins json-schema to 4.0.x, whose parser passes the obsolete
# quirks_mode option rejected by JSON 3. Backport the upstream parser fix until
# the schemas gem allows json-schema >= 6.2.1:
# https://github.com/voxpupuli/json-schema/pull/578
module JsonSchemaParser
  def parse(json)
    return super unless json_backend.to_s == 'json'

    JSON.parse(json)
  rescue JSON::ParserError => e
    raise JSON::Schema::JsonParseError, e.message
  end
end

JSON::Validator.singleton_class.prepend(JsonSchemaParser)
