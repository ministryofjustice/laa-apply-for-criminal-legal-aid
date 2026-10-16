module Steps
  module Income
    module Partner
      class SelfAssessmentTaxBillPaymentForm < Steps::BaseFormObject
        include Steps::HasOneAssociation

        has_one_association :income

        attribute :partner_self_assessment_tax_bill_amount, :pence
        attribute :partner_self_assessment_tax_bill_frequency, :value_object, source: PaymentFrequencyType

        validates :partner_self_assessment_tax_bill_amount, numericality: { greater_than_or_equal_to: 0 }
        validates :partner_self_assessment_tax_bill_frequency, inclusion: { in: PaymentFrequencyType.values }

        private

        def persist!
          income.update!(attributes)
        end
      end
    end
  end
end
