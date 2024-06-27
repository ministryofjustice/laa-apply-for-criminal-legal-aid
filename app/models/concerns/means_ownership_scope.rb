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
end
