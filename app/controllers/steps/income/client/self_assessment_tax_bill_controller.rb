module Steps
  module Income
    module Client
      class SelfAssessmentTaxBillController < Steps::IncomeStepController
        def edit
          @form_object = SelfAssessmentTaxBillForm.build(
            current_crime_application
          )
        end

        def update
          update_and_advance(SelfAssessmentTaxBillForm, as: :client_self_assessment_tax_bill)
        end
      end
    end
  end
end
