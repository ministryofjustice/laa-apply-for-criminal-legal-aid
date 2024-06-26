class Provider < ApplicationRecord
  devise :lockable, :timeoutable, :reauthable, :trackable,
         :omniauthable, omniauth_providers: %i[saml]

  store_accessor :settings,
                 :selected_office_code,
                 :legal_rep_has_partner_declaration,
                 :legal_rep_no_partner_declaration_reason,
                 :legal_rep_first_name,
                 :legal_rep_last_name,
                 :legal_rep_telephone

  def display_name
    email
  end

  def multiple_offices?
    office_codes.size > 1
  end

  class << self
    def from_omniauth(auth)
      find_or_initialize_by(auth_provider: auth.provider, uid: auth.uid).tap do |record|
        record.update(
          email: auth.info.email,
          description: auth.info.description,
          roles: auth.info.roles,
          office_codes: active_office_codes(auth)
        )

        ensure_default_office(record)
      end
    end

    private

    # If `selected_office_code` is nil or unknown, and there is
    # only one office returned, it defaults to that office.
    # If there are more offices, the provider will choose one.
    def ensure_default_office(record)
      return if record.office_codes.include?(record.selected_office_code)

      record.update(
        selected_office_code: (
          record.office_codes.first unless record.multiple_offices?
        )
      )
    end

    def active_office_codes(auth)
      Providers::ActiveOfficeChecker.new(auth.info).active_office_codes
    end
  end
end
