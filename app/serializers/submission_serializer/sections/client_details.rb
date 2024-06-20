module SubmissionSerializer
  module Sections
    class ClientDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          next unless applicant

          json.client_details do
            json.applicant Definitions::Applicant.generate(crime_application)
            json.partner Definitions::Partner.generate(crime_application) if partner
          end
        end
      end
    end
  end
end
