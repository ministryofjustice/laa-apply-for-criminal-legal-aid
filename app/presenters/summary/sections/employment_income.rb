module Summary
  module Sections
    class EmploymentIncome < Sections::BaseSection
      def show?
        employment_income.present? && super
      end

      def answers
        [
          Components::PaymentAnswer.new(
            'employments.applicant_employment_income', employment_income,
            change_path: edit_steps_income_client_employment_income_path
          )
        ].select(&:show?)
      end

      def employment_income
        crime_application.income_payments.employment
      end
    end
  end
end
