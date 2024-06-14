class MeansStatus
  include TypeOfMeansAssessment

  def initialize(crime_application)
    @crime_application = crime_application
  end

  class << self
    def include_partner?(crime_application)
      new(crime_application).include_partner_in_means_assessment?
    end
  end

  private

  attr_reader :crime_application
end
