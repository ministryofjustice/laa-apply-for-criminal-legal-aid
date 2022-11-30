module SubmissionSerializer
  module Sections
    class ClientDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.client_details do
            json.applicant Definitions::Applicant.generate(crime_application.applicant)
          end
        end
      end
    end
  end
end
