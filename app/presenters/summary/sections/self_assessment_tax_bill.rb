module Summary
  module Sections
    class SelfAssessmentTaxBill < Sections::BaseSection
      include HasDynamicSubject

      SelfAssessmentTaxBillPayment = Struct.new(:amount, :frequency)

      def show?
        income.present? && income.applicant_self_assessment_tax_bill.present?
      end

      def answers # rubocop:disable Metrics/MethodLength
        answers = [
          Components::ValueAnswer.new(
            :self_assessment_tax_bill, income.applicant_self_assessment_tax_bill,
            change_path: edit_steps_income_client_self_assessment_tax_bill_path
          )
        ]

        if income.applicant_self_assessment_tax_bill == YesNoAnswer::YES.to_s
          answers << Components::PaymentAnswer.new(
            :self_assessment_tax_bill_payment, self_assessment_tax_bill_payment,
            change_path: edit_steps_income_client_self_assessment_tax_bill_path
          )
        end

        answers
      end

      def self_assessment_tax_bill_payment
        SelfAssessmentTaxBillPayment.new(
          amount: income.applicant_self_assessment_tax_bill_amount,
          frequency: income.applicant_self_assessment_tax_bill_frequency
        )
      end
    end
  end
end
