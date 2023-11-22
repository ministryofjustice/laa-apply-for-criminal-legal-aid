module SubmissionSerializer
  module Sections
    class MeansDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.means_details do
            if crime_application.income_details
              json.income_details do
                json.income_above_threshold crime_application.income_details.income_above_threshold

                json.lost_job_in_custody crime_application.applicant.lost_job_in_custody
                json.date_job_lost crime_application.applicant.date_job_lost
              end
            end
          end
        end
      end
    end
  end
end
