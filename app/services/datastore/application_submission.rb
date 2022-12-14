module Datastore
  class ApplicationSubmission
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    # rubocop:disable Metrics/MethodLength
    def call
      submitted_at = Time.current
      date_stamp = crime_application.date_stamp || submitted_at

      CrimeApplication.transaction do
        crime_application.update!(
          status: ApplicationStatus::SUBMITTED.value,
          submitted_at: submitted_at,
          date_stamp: date_stamp,
        )

        DatastoreApi::Requests::CreateApplication.new(
          payload: application_payload
        ).call

        crime_application.destroy
      end

      true
    rescue StandardError => e
      Rails.logger.error(e)
      Sentry.capture_exception(e)

      false
    end
    # rubocop:enable Metrics/MethodLength

    def application_payload
      SubmissionSerializer::Application.new(
        crime_application
      ).generate.as_json
    end
  end
end
