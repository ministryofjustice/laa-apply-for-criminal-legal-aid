class ApplicationSubmission
  attr_reader :crime_application

  def initialize(crime_application)
    @crime_application = crime_application
  end

  # TODO: for now we don't really know how the submission will work,
  # this is just a mock, and for now we just mark an application as
  # submitted, to enable post-submission journeys.
  # rubocop:disable Metrics/MethodLength
  def call
    submitted_at = Time.current
    date_stamp = crime_application.date_stamp || submitted_at

    crime_application.update!(
      status: ApplicationStatus::SUBMITTED.value,
      submitted_at: submitted_at,
      date_stamp: date_stamp,
    )

    if FeatureFlags.datastore_submission.enabled?
      DatastoreApi::Requests::CreateApplication.new(
        payload: {}
      ).call
    end

    true
  end
  # rubocop:enable Metrics/MethodLength

  private

  # :nocov:
  def application_payload
    SubmissionSerializer::Application.new(crime_application).generate
  end
  # :nocov:
end
