# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :crypt, :salt, :certificate,
  :SAMLRequest, :SAMLResponse, :Signature, :SigAlg, :KeyInfo,

  # Attributes relating to an application
  # It does partial matching (i.e. `telephone_number` is covered by `phone`)
  :address_line,
  :appeal_with_changes_details,
  :code,
  :date_of_birth,
  :description,
  :email,
  :first_name,
  :justification,
  :last_name,
  :lookup_id,
  :maat_id,
  :nino,
  :other_names,
  :phone,
  :postcode,
  :reason,
  :session_state,
  :state,
  :urn,
]
