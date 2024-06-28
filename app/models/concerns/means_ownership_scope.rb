module MeansOwnershipScope
  extend ActiveSupport::Concern

  #
  # Used in scopes and associations such as savings, properties, etc to
  # exclude things owned by the partner when there is a contrary interest.
  #
  def ownership_types
    app = is_a?(CrimeApplication) ? self : crime_application

    if MeansStatus.include_partner?(app)
      OwnershipType.values.map(&:to_s) << nil
    else
      [OwnershipType::APPLICANT.to_s, OwnershipType::APPLICANT_AND_PARTNER.to_s, nil]
    end
  end

  def employent_ownership_types
    scopes = []

    if income
      scopes << OwnershipType::APPLICANT.to_s if employed?(income.employment_status)
      scopes << OwnershipType::PARTNER.to_s if employed?(income.partner_employment_status)
    end

    scopes & ownership_types
  end

  private

  def employed?(statuses)
    statuses.include? EmploymentStatus::EMPLOYED.to_s
  end
end
