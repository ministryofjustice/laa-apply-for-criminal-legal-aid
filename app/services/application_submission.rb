class ApplicationSubmission
  attr_reader :crime_application

  def initialize(crime_application)
    @crime_application = crime_application
  end

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
        payload: application_payload
      ).call
    end

    true
  end
  # rubocop:enable Metrics/MethodLength

  def application_payload
    SubmissionSerializer::Application.new(
      crime_application
    ).generate.as_json
  end
end
