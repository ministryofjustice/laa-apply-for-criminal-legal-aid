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
          income.update!(attributes)
        end
      end
    end
  end
end
