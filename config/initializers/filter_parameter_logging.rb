# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
  :SAMLResponse, :Signature, :SigAlg, :KeyInfo,
  # Attributes relating to an application
  # It does partial matching (i.e. `telephone_number` is covered by `phone`)
  :first_name,
  :last_name,
  :other_names,
  :date_of_birth,
  :nino,
  :address_line,
  :postcode,
  :email,
  :phone,
  :urn,
  :maat_id,
  :reason,
  :description,
  :justification,
  :appeal_with_changes_details,
]
