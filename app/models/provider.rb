class Provider < ApplicationRecord
  devise :lockable, :timeoutable, :reauthable, :trackable,
         :omniauthable, omniauth_providers: [:entra]

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

  def selected_office_code
    return super if office_codes.include?(super)

    office_codes.first unless multiple_offices?
  end

  class << self
    def from_omniauth(auth)
      find_or_initialize_by(auth_provider: auth.provider, uid: auth.uid).tap do |record|
        record.update(
          email: auth.info.email,
          description: auth.info.description,
          roles: auth.info.roles,
          office_codes: auth.info.office_codes
        )
      end
    end
  end
end
