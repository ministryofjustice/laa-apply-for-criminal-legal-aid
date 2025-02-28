class MeansStatus
  include TypeOfMeansAssessment

  def initialize(crime_application)
    @crime_application = crime_application
  end

  class << self
    def include_partner?(crime_application)
      new(crime_application).include_partner_in_means_assessment?
    end

    def full_means_required?(crime_application)
      new(crime_application).requires_full_means_assessment?
    end

    def full_capital_required?(crime_application)
      new(crime_application).requires_full_capital?
    end

    def residence_owned?(crime_application)
      new(crime_application).residence_owned?
    end
  end

  private

  attr_reader :crime_application
end
