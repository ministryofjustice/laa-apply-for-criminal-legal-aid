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

  # :nocov:
  # TOOD add coverage before release
  has_many(
    :outgoings_payments,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )
  # :nocov:

  has_many(
    :national_savings_certificates,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  has_many(
    :savings,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  has_many(
    :investments,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  has_many(
    :businesses,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  has_many(
    :employments,
    -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
    through: :crime_application
  )

  # Utility methods for testing/output
  delegate :partner_detail, to: :crime_application

  def has_partner # rubocop:disable Naming/PredicateName
    partner_detail&.has_partner
  end

  def relationship_status
    partner_detail&.relationship_status
  end

  def separation_date
    partner_detail&.separation_date
  end

  def ownership_types
    [
      OwnershipType::APPLICANT.to_s,
      OwnershipType::APPLICANT_AND_PARTNER.to_s
    ]
  end

  def ownership_type
    OwnershipType::APPLICANT
  end
end
