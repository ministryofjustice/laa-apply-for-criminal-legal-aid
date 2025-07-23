# frozen_string_literal: true

Devise.setup do |config|
  require 'devise/orm/active_record'
  require 'devise/models/reauthable'
  require 'laa_portal/saml_strategy'
  require 'laa_portal/saml_setup'
  require 'lassie/oidc_strategy'

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = Rails.configuration.x.session.timeout_in

  # ==> Configuration for :reauthable
  # The time you want to timeout the user session after their last sign in,
  # regardless of their activity.
  config.reauthenticate_in = Rails.configuration.x.session.reauthenticate_in

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  config.lock_strategy = :none

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  config.unlock_strategy = :none

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  # config.last_attempt_warning = true

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  config.default_scope = :provider

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # Handle custom error pages redirects, instead of showing flash messages.
  config.warden do |manager|
    manager.failure_app = Devise::CustomFailureApp
  end

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  config.omniauth :saml,
                  name: :saml,
                  setup: LaaPortal::SamlSetup,
                  strategy_class: LaaPortal::SamlStrategy

  config.omniauth(
    :openid_connect,
    {
      name: :entra,
      scope: [:openid, :email],
      response_type: :code,
      send_nonce: true,
      client_options: {
        identifier: ENV.fetch('OMNIAUTH_ENTRA_CLIENT_ID', nil),
        secret: ENV.fetch('OMNIAUTH_ENTRA_CLIENT_SECRET', nil),
        redirect_uri: ENV.fetch('OMNIAUTH_ENTRA_REDIRECT_URI', nil)
      },
      discovery: true,
      pkce: true,
      issuer: "https://login.microsoftonline.com/#{ENV.fetch('OMNIAUTH_ENTRA_TENANT_ID', nil)}/v2.0",
      strategy_class: Lassie::OidcStrategy
    }
  )
end
