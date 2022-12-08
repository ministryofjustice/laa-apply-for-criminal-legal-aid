require 'warden/strategies/laa_portal_strategy'

Warden::Strategies.add(
  :laa_portal, Warden::Strategies::LaaPortalStrategy
)

Rails.application.config.middleware.insert_after(ActionDispatch::Flash, Warden::Manager) do |manager|
  manager.default_scope = :user
  manager.scope_defaults :user, strategies: [:laa_portal]

  manager.failure_app = Warden::UnauthorizedController

  manager.serialize_into_session(:user) { |user| user.as_json }
  manager.serialize_from_session(:user) { |session_data| Provider.new(session_data) }
end
