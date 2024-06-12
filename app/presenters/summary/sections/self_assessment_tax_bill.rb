module Summary
  module Sections
    class SelfAssessmentTaxBill < Sections::BaseSection
      def show?
        outgoings.present? && outgoings.applicant_self_assessment_tax_bill.present?
      end

      def answers # rubocop:disable Metrics/MethodLength
        answers = [
          Components::ValueAnswer.new(
            :self_assessment_tax_bill, outgoings.applicant_self_assessment_tax_bill,
            change_path: edit_steps_income_client_self_assessment_tax_bill_path
          )
        ]

        if outgoings.applicant_self_assessment_tax_bill == YesNoAnswer::YES.to_s
          answers << Components::PaymentAnswer.new(
            :self_assessment_tax_bill_payment, self_assessment_tax_bill,
            change_path: edit_steps_income_client_self_assessment_tax_bill_path
          )
        end

        answers
      end

      # :nocov:
      def self_assessment_tax_bill
        crime_application
          .outgoings_payments
          .detect { |payment| payment.payment_type == OutgoingsPaymentType::SELF_ASSESSMENT_TAX_BILL.to_s }
      end
      # :nocov:
    end
  end
end
