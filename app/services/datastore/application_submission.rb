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

      Rails.error.handle(fallback: -> { false }) do
        CrimeApplication.transaction do
          crime_application.assign_attributes(
            submitted_at:,
            date_stamp:,
          )

          DatastoreApi::Requests::CreateApplication.new(
            payload: application_payload
          ).call

          crime_application.destroy!
        end

        true
      end
    end
    # rubocop:enable Metrics/MethodLength

    def application_payload
      serializer_klass.new(crime_application).generate.as_json
    end

    def serializer_klass
      SubmissionSerializer.const_get(Types::ApplicationType[application_type].camelize)
    end
  end
end
