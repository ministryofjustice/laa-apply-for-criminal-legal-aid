class ApplicationAmendment
  attr_reader :crime_application

  def initialize(crime_application)
    @crime_application = crime_application
  end

  # TODO: for now we don't really know how the amendment will work,
  # this is just a mock, and for now we just mark an application as
  # `in_progress`, to re-enable the steps journey.
  #
  # Presumably, the act of "amending" an application will mean
  # creating a "copy" of the last submitted version, with a
  # reference to it (`parent_id`). To be decided.
  #
  def call
    crime_application.update!(
      status: ApplicationStatus::IN_PROGRESS.value,
      # we reset some values
      navigation_stack: [],
      declaration_signed: nil,
      submitted_at: nil,
    )
  end
end
