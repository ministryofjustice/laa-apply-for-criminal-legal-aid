module SubmissionSerializer
  module Sections
    class ClientDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          next unless applicant

          json.client_details do
            json.applicant Definitions::Applicant.generate(crime_application)

            json.partner partner_json unless crime_application.non_means_tested?
          end
        end
      end

      private

      def partner_json
        return unless crime_application.partner

        Definitions::Partner.generate(crime_application)
      end
    end
  end
end
