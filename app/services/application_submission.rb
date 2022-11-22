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
  # https://github.com/ministryofjustice/laa-criminal-legal-aid-schemas
  def application_payload
    application_details.merge(client_details:).to_json
  end

  def application_details
    details = { reference: crime_application.usn, schema_version: 0.1 }

    %i[id status created_at submitted_at date_stamp].each do |attribute|
      details[attribute] = crime_application.send(attribute)
    end

    details
  end

  def client_details
    details = { applicant: {} }

    %i[first_name last_name date_of_birth nino].each do |attribute|
      details[:applicant][attribute] = crime_application.applicant.send(attribute)
    end

    details
  end
end
