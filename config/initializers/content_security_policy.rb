# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :none
    policy.base_uri    :none
    policy.style_src   :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data, 'https://*.google-analytics.com', 'https://*.googletagmanager.com'
    policy.connect_src :self, 'https://ga.jspm.io', 'https://*.google-analytics.com', 'https://*.analytics.google.com', 'https://*.googletagmanager.com'
    policy.form_action :self, 'https://*.legalservices.gov.uk/oamfed/idp/samlv20'
    policy.script_src  :strict_dynamic

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
