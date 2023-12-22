module Summary
  module Sections
    class EmploymentDetails < Sections::BaseSection
      def show?
        income.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
          Components::ValueAnswer.new(
            # TODO: Handle array of employment_statuses when designs for employed available
            :employment_status, income.employment_status.first,
            change_path: edit_steps_income_employment_status_path
          ),
          Components::ValueAnswer.new(
            :ended_employment_within_three_months, income.ended_employment_within_three_months,
            change_path: edit_steps_income_employment_status_path
          ),
          Components::ValueAnswer.new(
            :lost_job_in_custody, income.lost_job_in_custody,
            change_path: edit_steps_income_lost_job_in_custody_path
          ),
          Components::DateAnswer.new(
            :date_job_lost, income.date_job_lost,
            change_path: edit_steps_income_lost_job_in_custody_path
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def income
        @income ||= crime_application.income
      end
    end
  end
end
