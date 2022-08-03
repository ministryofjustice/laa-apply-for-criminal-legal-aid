module HasContactDetailsThroughPeople
  extend ActiveSupport::Concern

  included do
    # Just syntax-sugar to simplify form objects 2nd level associations
    # when using the `Steps::HasOneAssociation` concern
    has_one :applicant_contact_details, source: :contact_details, through: :applicant
    has_one :partner_contact_details,   source: :contact_details, through: :partner
  end

  # The usual `#build_xyz` will not work properly with `through` associations
  # so we just implement our own build methods using the intermediate tables
  def build_applicant_contact_details
    applicant.build_contact_details
  end

  def build_partner_contact_details
    partner.build_contact_details
  end
end
