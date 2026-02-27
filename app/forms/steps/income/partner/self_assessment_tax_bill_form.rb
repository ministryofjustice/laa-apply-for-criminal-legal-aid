module Steps
  module Income
    module Partner
      class SelfAssessmentTaxBillForm < Steps::BaseFormObject
        include Steps::HasOneAssociation

        has_one_association :income

        attribute :partner_self_assessment_tax_bill, :value_object, source: YesNoAnswer
        attribute :partner_self_assessment_tax_bill_amount, :pence
        attribute :partner_self_assessment_tax_bill_frequency, :value_object, source: PaymentFrequencyType

        validates :partner_self_assessment_tax_bill, inclusion: { in: YesNoAnswer.values }
        validates :partner_self_assessment_tax_bill_amount,
                  numericality: { greater_than_or_equal_to: 0 }, if: -> { pays_self_assessment_tax_bill? }
        validates :partner_self_assessment_tax_bill_frequency,
                  inclusion: { in: PaymentFrequencyType.values }, if: -> { pays_self_assessment_tax_bill? }

        private

        def persist!
          income.update!(attributes)
        end

        def pays_self_assessment_tax_bill?
          partner_self_assessment_tax_bill&.yes?
        end

        def before_save
          return if pays_self_assessment_tax_bill?

          self.partner_self_assessment_tax_bill_amount = nil
          self.partner_self_assessment_tax_bill_frequency = nil
        end
      end
    end
  end
end
