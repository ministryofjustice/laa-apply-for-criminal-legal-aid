module Summary
  module Sections
    class WorkBenefits < Sections::BaseSection
      def show?
        income.present? && income.applicant_other_work_benefit_received.present?
      end

      def answers # rubocop:disable Metrics/MethodLength
        answers = [
          Components::ValueAnswer.new(
            :work_benefits, income.applicant_other_work_benefit_received,
            change_path: edit_steps_income_client_other_work_benefits_path
          )
        ]

        if income.applicant_other_work_benefit_received == YesNoAnswer::YES.to_s
          answers << Components::PaymentAnswer.new(
            :work_benefits_payment, work_benefits,
            change_path: edit_steps_income_client_other_work_benefits_path
          )
        end

        answers
      end

      # :nocov:
      def work_benefits
        crime_application
          .income_payments
          .detect { |payment| payment.payment_type == IncomePaymentType::WORK_BENEFITS.to_s }
      end
      # :nocov:
    end
  end
end
