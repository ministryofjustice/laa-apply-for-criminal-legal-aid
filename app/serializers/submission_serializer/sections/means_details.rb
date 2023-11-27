module SubmissionSerializer
  module Sections
    class MeansDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.means_details do
            json.income_details do
              income_above_threshold(json)
              lost_job_in_custody(json)
            end
          end
        end
      end

      private

      def income_above_threshold(json)
        return unless crime_application.income

        json.income_above_threshold crime_application.income.income_above_threshold
      end

      def lost_job_in_custody(json)
        return unless crime_application&.income&.lost_job_in_custody

        json.lost_job_in_custody crime_application.income.lost_job_in_custody
        json.date_job_lost crime_application.income.date_job_lost
      end
    end
  end
end
