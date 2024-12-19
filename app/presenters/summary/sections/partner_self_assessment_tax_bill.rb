module Summary
  module Sections
    class PartnerSelfAssessmentTaxBill < Sections::BaseSection
      include HasDynamicSubject

      SelfAssessmentTaxBillPayment = Struct.new(:amount, :frequency)

      def show?
        income.present? &&
          MeansStatus.include_partner?(crime_application) &&
          income.partner_self_assessment_tax_bill.present?
      end

      def answers # rubocop:disable Metrics/MethodLength
        answers = [
          Components::ValueAnswer.new(
            :partner_self_assessment_tax_bill, income.partner_self_assessment_tax_bill,
            change_path: edit_steps_income_partner_self_assessment_tax_bill_path
          )
        ]

        if income.partner_self_assessment_tax_bill == YesNoAnswer::YES.to_s
          answers << Components::PaymentAnswer.new(
            :partner_self_assessment_tax_bill_payment, self_assessment_tax_bill_payment,
            change_path: edit_steps_income_partner_self_assessment_tax_bill_path
          )
        end

        answers
      end

      def self_assessment_tax_bill_payment
        SelfAssessmentTaxBillPayment.new(
          amount: income.partner_self_assessment_tax_bill_amount,
          frequency: income.partner_self_assessment_tax_bill_frequency
        )
      end

      private

      def subject_type
        SubjectType.new(:partner)
      end
    end
  end
end
