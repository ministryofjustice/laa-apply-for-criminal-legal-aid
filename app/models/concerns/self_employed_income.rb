module SelfEmployedIncome
  extend ActiveSupport::Concern

  def self_employed_owners
    owners = []
    owners << OwnershipType::APPLICANT.to_s if client_employed?
    owners << OwnershipType::PARTNER.to_s if partner_employed?

    owners
  end
end
