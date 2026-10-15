module Steps
  module Income
    module Client
      class SelfAssessmentTaxBillForm < Steps::BaseFormObject
        include Steps::HasOneAssociation

        has_one_association :income

        attribute :applicant_self_assessment_tax_bill, :value_object, source: YesNoAnswer

        validates :applicant_self_assessment_tax_bill, inclusion: { in: YesNoAnswer.values }

        private

        def persist!
          income.update!(attributes)
        end
      end
    end
  end
end
