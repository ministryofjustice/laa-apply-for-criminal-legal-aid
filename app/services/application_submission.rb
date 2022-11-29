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

  # Just a quick and dirty example.
  # What we want eventually is a proper adapter to transform
  # the application record into the expected JSON document,
  # conforming to the agreed schema.
  # https://github.com/ministryofjustice/laa-criminal-legal-aid-schemas
  # :nocov:
  def application_payload
    crime_application.as_json(
      only: [:id, :status, :created_at, :submitted_at, :date_stamp]
    ).merge(
      client_details: {
        applicant: crime_application.applicant.as_json
      },
      reference: crime_application.usn,
      schema_version: 0.1,
    )
  end
  # :nocov:
end
