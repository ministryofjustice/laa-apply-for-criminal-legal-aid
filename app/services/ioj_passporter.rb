class IojPassporter
  attr_reader :crime_application

  def initialize(crime_application)
    @crime_application = crime_application
  end

  def call
    ioj_passport = if applicant_under18_passport?
                     crime_application.ioj_passport | [IojPassportType::ON_AGE_UNDER18.to_s]
                   else
                     crime_application.ioj_passport - [IojPassportType::ON_AGE_UNDER18.to_s]
                   end

    crime_application.update(ioj_passport:)
    crime_application.ioj_passport.any?
  end

  def applicant_under18_passport?
    return false unless FeatureFlags.u18_ioj_passport.enabled?

    AgeCalculator.new(crime_application.applicant).under18?
  end
end
