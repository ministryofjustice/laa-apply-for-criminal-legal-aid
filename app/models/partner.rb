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
end
