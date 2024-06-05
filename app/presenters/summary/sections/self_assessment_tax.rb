module Summary
  module Sections
    class SelfAssessmentTax < Sections::BaseSection
      def show?
        income.applicant_self_assessment_tax_bill.present? && super
      end

      def answers # rubocop:disable Metrics/MethodLength
        answers = [
          Components::ValueAnswer.new(
            'employments.applicant_self_assessment_tax_bill_question', income.applicant_self_assessment_tax_bill,
            change_path: edit_steps_income_client_self_assessment_tax_bill_path
          )
        ]

        if income.applicant_self_assessment_tax_bill == 'yes' && self_assessment_tax_bill.present?
          answers << Components::PaymentAnswer.new(
            'employments.applicant_self_assessment_tax_bill_amount', self_assessment_tax_bill,
            change_path: edit_steps_income_client_self_assessment_tax_bill_path
          )
        end
        answers.select(&:show?)
      end

      def self_assessment_tax_bill
        crime_application.outgoings_payments.self_assessment_tax_bill
      end
    end
  end
end
