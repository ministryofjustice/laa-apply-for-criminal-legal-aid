class IojPassporter
  def initialize(applicant, kase)
    @applicant = applicant
    @case = kase
  end

  def call
    return false unless under_18_passporting_enabled?

    ioj_passport = if applicant_age(@applicant.date_of_birth) < 18
                     @case.ioj_passport | [IojPassportType::ON_AGE_UNDER18.to_s]
                   else
                     @case.ioj_passport - [IojPassportType::ON_AGE_UNDER18.to_s]
                   end
    @case.update(ioj_passport:)
    @case.ioj_passport.any?
  end

  private

  def under_18_passporting_enabled?
    FeatureFlags.u18_ioj_passport.enabled?
  end

  # rubocop:disable Metrics/AbcSize
  def applicant_age(dob)
    years = Time.zone.now.year - dob.year
    years -= 1 if Time.zone.now.month < dob.month
    years -= 1 if Time.zone.now.month == dob.month && Time.zone.now.day < dob.day

    years
  end
  # rubocop:enable Metrics/AbcSize
end
