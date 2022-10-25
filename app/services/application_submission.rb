class ApplicationSubmission
  attr_reader :crime_application

  def initialize(crime_application)
    @crime_application = crime_application
  end

  # TODO: for now we don't really know how the submission will work,
  # this is just a mock, and for now we just mark an application as
  # submitted, to enable post-submission journeys.
  #
  def call
    crime_application.update!(
      status: ApplicationStatus::SUBMITTED.value,
      submitted_at: Time.current,
    )
  end
end
