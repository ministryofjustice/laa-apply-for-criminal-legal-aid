module SubmissionSerializer
  module Sections
    class MeansDetails < Sections::BaseSection
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          if income.present?
            json.means_details do
              json.income_details do
                json.income_above_threshold income.income_above_threshold
                json.employment_type income.employment_status
                json.ended_employment_within_three_months income.ended_employment_within_three_months
                json.lost_job_in_custody income.lost_job_in_custody
                json.date_job_lost income.date_job_lost
                json.has_frozen_income_or_assets income.has_frozen_income_or_assets
                json.has_savings income.has_savings
                json.manage_without_income income.manage_without_income
                json.manage_other_details income.manage_other_details
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def income
        @income ||= crime_application.income
      end
    end
  end
end
