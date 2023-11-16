module Summary
  module Sections
    class EmploymentDetails < Sections::BaseSection
      def name
        :employment_details
      end

      def show?
        income_details.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            # TODO Update once employment status can be Array of employed types
            :employment_status, income_details.employment_status.first,
            change_path: edit_steps_income_employment_status_path
          ),
          Components::ValueAnswer.new(
            :ended_employment_within_three_months, income_details.ended_employment_within_three_months,
            change_path: edit_steps_income_employment_status_path
          ),
          Components::ValueAnswer.new(
            :lost_job_in_custody, income_details.lost_job_in_custody,
            change_path: edit_steps_income_lost_job_in_custody_path
          ),
          Components::DateAnswer.new(
            :date_job_lost, income_details.date_job_lost,
            change_path: edit_steps_income_lost_job_in_custody_path
          ),
        ].select(&:show?)
      end

      private

      def income_details
        @income_details ||= crime_application.income_details
      end
    end
  end
end
