module Datastore
  class PostSubmissionEvidence
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    # rubocop:disable Metrics/MethodLength
    def call
      submitted_at = Time.current

      Rails.error.handle(fallback: -> { false }) do
        CrimeApplication.transaction do
          crime_application.assign_attributes(
            submitted_at:
          )

          DatastoreApi::Requests::CreatePostSubmissionEvidence.new(
            payload: application_payload
          ).call

          crime_application.destroy!
        end

        true
      end
    end
    # rubocop:enable Metrics/MethodLength

    def application_payload
      SubmissionSerializer::Application.new(
        crime_application
      ).generate.as_json
    end
  end
end
