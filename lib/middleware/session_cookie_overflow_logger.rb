# app/middleware/session_cookie_overflow_logger.rb
# frozen_string_literal: true

class SessionCookieOverflowLogger
  MAX_LOGGED_KEYS = 20

  def initialize(app, logger: Rails.logger)
    @app = app
    @logger = logger
  end

  def call(env) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @app.call(env)
  rescue ActionDispatch::Cookies::CookieOverflow => e
    session = env['rack.session']
    session_hash = session.respond_to?(:to_hash) ? session.to_hash : {}

    session_values = session_hash.transform_values do |value|
      {
        class: value.class.name,
        estimated_bytes: estimated_bytes(value)
      }
    end

    largest_session_keys = session_values
                           .sort_by { |_key, metadata| -metadata[:estimated_bytes] }
                           .first(MAX_LOGGED_KEYS)
                           .to_h

    @logger.error(
      {
        event: 'session_cookie_overflow',
        exception: e.class.name,
        message: e.message,
        request_path: env['PATH_INFO'],
        request_method: env['REQUEST_METHOD'],
        request_id: env['action_dispatch.request_id'],
        session_key_count: session_hash.size,

        # Approximate size of the Ruby session payload. This is not the
        # final cookie size, which includes Rails serialization,
        # encryption and signing overhead.
        estimated_session_payload_bytes: session_values.sum { |_key, metadata| metadata[:estimated_bytes] },

        largest_session_keys: largest_session_keys,

        omniauth_params: omniauth_param_sizes(session_hash)
      }.to_json
    )

    raise
  end

  private

  def estimated_bytes(value)
    Marshal.dump(value).bytesize
  rescue StandardError
    value.to_s.bytesize
  end

  def omniauth_param_sizes(session_hash)
    omniauth_params = session_hash['omniauth.params']
    return unless omniauth_params.is_a?(Hash)

    param_sizes = omniauth_params.transform_values do |value|
      {
        class: value.class.name,
        estimated_bytes: estimated_bytes(value)
      }
    end

    param_sizes.sort_by { |_key, metadata| -metadata[:estimated_bytes] }.to_h
  end
end
