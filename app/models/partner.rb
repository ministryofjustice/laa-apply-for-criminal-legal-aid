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
    :savings,
    -> { where(ownership_type: OwnershipType::PARTNER.to_s) },
    through: :crime_application
  )

  has_many(
    :investments,
    -> { where(ownership_type: OwnershipType::PARTNER.to_s) },
    through: :crime_application
  )
end
