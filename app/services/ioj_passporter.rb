class IojPassporter
  def initialize(applicant, kase)
    @applicant = applicant
    @case = kase
  end

  def call
    under_18_passporting_enabled?

    if applicant_age(@applicant.date_of_birth) < 18
      ioj_passport = @case.ioj_passport << IojPassportType.new('on_age_under18')
      @case.update(ioj_passport:)
    else
      false
    end
  end

  private

  def under_18_passporting_enabled?
    return false unless FeatureFlags.u18_ioj_passport.enabled?
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
