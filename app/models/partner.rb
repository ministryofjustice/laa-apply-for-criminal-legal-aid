class Partner < Person
  has_many(
    :income_payments,
    -> { where(ownership_type: OwnershipType::PARTNER.to_s) },
    through: :crime_application
  )

  has_many(
    :income_benefits,
    -> { where(ownership_type: OwnershipType::PARTNER.to_s) },
    through: :crime_application
  )

  has_many(
    :national_savings_certificates,
    -> { where(ownership_type: OwnershipType::PARTNER.to_s) },
    through: :crime_application
  )

  has_many(
    :businesses,
    -> { where(ownership_type: OwnershipType::PARTNER.to_s) },
    through: :crime_application
  )

  def to_param
    'partner'
  end

  def ownership_type
    OwnershipType::PARTNER
  end

  def ownership_types
    [OwnershipType::PARTNER, OwnershipType::APPLICANT_AND_PARTNER]
  end
end
