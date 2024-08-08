module SelfEmployedIncome
  extend ActiveSupport::Concern

  def self_employed_owners
    owners = []
    owners << OwnershipType::APPLICANT.to_s if client_self_employed?
    owners << OwnershipType::PARTNER.to_s if partner_self_employed?

    owners
  end

  def client_businesses
    businesses.select { |e| e.ownership_type == OwnershipType::APPLICANT.to_s }
  end

  def partner_businesses
    businesses.select { |e| e.ownership_type == OwnershipType::PARTNER.to_s }
  end

  def partner_self_employed?
    partner_employment_status.include? EmploymentStatus::SELF_EMPLOYED.to_s
  end

  def client_self_employed?
    employment_status.include? EmploymentStatus::SELF_EMPLOYED.to_s
  end
end
