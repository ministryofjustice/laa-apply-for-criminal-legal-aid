module SubmissionSerializer
  module Sections
    class MeansDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          if income.present?
            json.means_details do
              json.income_details do
                json.income_above_threshold income.income_above_threshold
                json.employment_type income.employment_status
                ended_employment_within_three_months(json)
                lost_job_in_custody(json)
              end
            end
          end
        end
      end

      private

      def lost_job_in_custody(json)
        return unless income&.lost_job_in_custody

        json.lost_job_in_custody income.lost_job_in_custody
        json.date_job_lost income.date_job_lost
      end

      def ended_employment_within_three_months(json)
        return unless income&.ended_employment_within_three_months

        json.ended_employment_within_three_months income.ended_employment_within_three_months
      end

      def income
        crime_application.income
      end
    end
  end
end
