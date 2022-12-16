class Provider < ApplicationRecord
  devise :lockable, :timeoutable, :trackable,
         :omniauthable, omniauth_providers: %i[saml]

  def self.from_omniauth(auth)
    find_or_initialize_by(auth_provider: auth.provider, uid: auth.uid).tap do |record|
      record.update(
        email: auth.info.email,
        description: auth.info.description,
        roles: auth.info.roles.split(','),
        office_codes: auth.info.office_codes.split(','),
      )
    end
  end

  def display_name
    uid
  end
end
