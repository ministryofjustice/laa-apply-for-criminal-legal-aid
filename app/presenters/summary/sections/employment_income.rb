module Summary
  module Sections
    class EmploymentIncome < Sections::BaseSection
      def show?
        crime_application.income.applicant_other_work_benefit_received.present?
      end

      def answers
        [
          Components::PaymentAnswer.new(
            :employment_income, employment_income,
            change_path: edit_steps_income_client_employment_income_path
          )
        ]
      end

      def employment_income
        crime_application
          .income_payments
          .detect { |payment| payment.payment_type == IncomePaymentType::EMPLOYMENT.to_s }
      end
    end
  end
end
