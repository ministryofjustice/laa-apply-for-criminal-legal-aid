module Datastore
  class ApplicationSubmission
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    def call
      Rails.error.handle(fallback: -> { false }) do
        CrimeApplication.transaction do
          crime_application.assign_attributes(
            submitted_at: Time.current
          )

          DatastoreApi::Requests::CreateApplication.new(
            payload: application_payload
          ).call

          crime_application.destroy!
        end

        true
      end
    end

    def application_payload
      SubmissionSerializer::Application.new(
        crime_application
      ).generate.as_json
    end
  end
end
