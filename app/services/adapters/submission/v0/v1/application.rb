module Adapters
  module Submission
    module V0
      module V1
        class Application
          def initialize(crime_application)
            @crime_application = crime_application
            @applicant = crime_application.applicant
          end

          def call
            application_details.merge(client_details:).to_json
          end

          private

          def application_details
            details = { reference: @crime_application.usn, schema_version: 0.1 }

            %i[id status created_at submitted_at date_stamp].each do |attribute|
              details[attribute] = @crime_application.send(attribute)
            end

            details
          end

          def client_details
            details = { applicant: {} }

            %i[first_name last_name date_of_birth nino].each do |attribute|
              details[:applicant][attribute] = @applicant.send(attribute)
            end

            details
          end
        end
      end
    end
  end
end
