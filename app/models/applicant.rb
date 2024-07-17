class Applicant < Person
  has_many(
    :income_payments,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  has_many(
    :income_benefits,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  has_many(
    :national_savings_certificates,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  has_many(
    :businesses,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  def to_param
    'client'
  end

  # Utility methods for testing/output
  delegate :partner_detail, to: :crime_application

  def has_partner
    partner_detail&.has_partner
  end

  def relationship_status
    partner_detail&.relationship_status
  end

  def separation_date
    partner_detail&.separation_date
  end

  def ownership_type
    OwnershipType::APPLICANT
  end

  def ownership_types
    [OwnershipType::APPLICANT, OwnershipType::APPLICANT_AND_PARTNER]
  end
end
