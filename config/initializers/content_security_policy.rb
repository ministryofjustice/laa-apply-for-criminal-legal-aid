require 'feature_flags'

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri    :none
    policy.style_src   :self
    policy.font_src    :self

    if FeatureFlags.google_analytics.enabled?
      policy.connect_src :self, 'https://ga.jspm.io', 'https://*.google-analytics.com', 'https://*.analytics.google.com', 'https://*.googletagmanager.com'
      policy.img_src :self, 'https://*.google-analytics.com', 'https://*.googletagmanager.com'
    else
      policy.img_src :self
    end

    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
