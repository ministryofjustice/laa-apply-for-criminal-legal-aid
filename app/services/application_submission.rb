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

    # :nocov:
    if FeatureFlags.datastore_submission.enabled?
      DatastoreApi::Requests::CreateApplication.new(
        payload: application_payload
      ).call
    end
    # :nocov:

    true
  end
  # rubocop:enable Metrics/MethodLength

  private

  # Just a quick and dirty example.
  # What we want eventually is a proper adapter to transform
  # the application record into the expected JSON document,
  # conforming to the agreed schema.
  # :nocov:
  def application_payload
    crime_application.as_json(
      only: [:id, :usn, :status, :created_at, :submitted_at, :date_stamp]
    ).merge(
      client_details: crime_application.applicant.as_json,
      schema_version: 1.0,
    )
  end
  # :nocov:
end
