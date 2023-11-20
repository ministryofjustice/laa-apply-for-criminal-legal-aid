module SubmissionSerializer
  module Sections
    class MeansDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|

          json.means_details do
            json.income_details do
              json.income_above_threshold crime_application.income_details.income_above_threshold
            end

            json.not_working do
              json.lost_job_in_custody crime_application.applicant.lost_job_in_custody
              json.date_job_lost crime_application.applicant.date_job_lost
            end
          end
        end
      end
    end
  end
end
