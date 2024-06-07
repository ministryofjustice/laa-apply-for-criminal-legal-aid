module Summary
  module Sections
    class SelfAssessmentTaxBill < Sections::BaseSection
      def show?
        crime_application.outgoings.applicant_self_assessment_tax_bill.present?
      end

      def answers
        answers = [
          Components::ValueAnswer.new(
            :self_assessment_tax_bill, crime_application.outgoings.applicant_self_assessment_tax_bill,
            change_path: edit_steps_income_client_self_assessment_tax_bill_path
          )
        ]

        if crime_application.outgoings.applicant_self_assessment_tax_bill == YesNoAnswer::YES.to_s
          answers << Components::PaymentAnswer.new(
            :self_assessment_tax_bill_payment, self_assessment_tax_bill,
            change_path: edit_steps_income_client_self_assessment_tax_bill_path
          )
        end

        answers
      end

      def self_assessment_tax_bill
        crime_application
          .outgoings_payments
          .detect { |payment| payment.payment_type == OutgoingsPaymentType::SELF_ASSESSMENT_TAX_BILL.to_s }
      end
    end
  end
end
