module SubmissionSerializer
  module Sections
    class LostJobInCustodyDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.income_details do
            json.lost_job_in_custody crime_application.applicant.lost_job_in_custody
            json.lost_job_in_custody crime_application.applicant.lost_job_in_custody
          end
        end
      end
    end
  end
end
