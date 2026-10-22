module Steps
  module Income
    module Partner
      class SelfAssessmentTaxBillForm < Steps::BaseFormObject
        include Steps::HasOneAssociation

        has_one_association :income

        attribute :partner_self_assessment_tax_bill, :value_object, source: YesNoAnswer

        validates :partner_self_assessment_tax_bill, inclusion: { in: YesNoAnswer.values }

        private

        def persist!
          income.update!(attributes.merge(payment_attributes))
        end

        def payment_attributes
          return {} if partner_self_assessment_tax_bill&.yes?

          {
            partner_self_assessment_tax_bill_amount: nil,
            partner_self_assessment_tax_bill_frequency: nil
          }
        end
      end
    end
  end
end
