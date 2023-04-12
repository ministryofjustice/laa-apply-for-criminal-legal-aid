class AgeCalculator
  attr_reader :crime_application

  def initialize(crime_application)
    @crime_application = crime_application
  end

  def applicant_under18?
    dob = crime_application.applicant.date_of_birth
    dob + 18.years > Time.zone.today
  end
end
