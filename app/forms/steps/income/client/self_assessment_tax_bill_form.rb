module Steps
  module Income
    module Client
      class SelfAssessmentTaxBillForm < Steps::BaseFormObject
        include Steps::HasOneAssociation
        has_one_association :income

        attribute :applicant_self_assessment_tax_bill, :value_object, source: YesNoAnswer
        attribute :applicant_self_assessment_tax_bill_amount, :pence
        attribute :applicant_self_assessment_tax_bill_frequency, :value_object, source: PaymentFrequencyType

        validates :applicant_self_assessment_tax_bill, inclusion: { in: YesNoAnswer.values }
        validates :applicant_self_assessment_tax_bill_amount,
                  numericality: { greater_than: 0 }, if: -> { pays_self_assessment_tax_bill? }
        validates :applicant_self_assessment_tax_bill_frequency,
                  inclusion: { in: PaymentFrequencyType.values }, if: -> { pays_self_assessment_tax_bill? }

        private

        def persist!
          income.update!(attributes)
        end

        def pays_self_assessment_tax_bill?
          applicant_self_assessment_tax_bill&.yes?
        end

        def before_save
          return if pays_self_assessment_tax_bill?

          self.applicant_self_assessment_tax_bill_amount = nil
          self.applicant_self_assessment_tax_bill_frequency = nil
        end
      end
    end
  end
end
