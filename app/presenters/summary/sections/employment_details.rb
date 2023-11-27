module Summary
  module Sections
    class EmploymentDetails < Sections::BaseSection
      def name
        :employment_details
      end

      def show?
        income.present? && super
      end

      def answers
        [
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

      private

      def income
        @income ||= crime_application.income
      end
    end
  end
end
