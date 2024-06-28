module PersonEmployments
  extend ActiveSupport::Concern

  def client_employments
    employments.to_a.select { |e| e.ownership_type == OwnershipType::APPLICANT.to_s }
  end

  def partner_employments
    employments.select { |e| e.ownership_type == OwnershipType::PARTNER.to_s }
  end
end
