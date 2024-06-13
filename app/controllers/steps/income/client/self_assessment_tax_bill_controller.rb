module Steps
  module Income
    module Client
      class SelfAssessmentTaxBillController < Steps::IncomeStepController
        def edit
          @form_object = SelfAssessmentTaxBillForm.build(
            current_crime_application.income, crime_application: current_crime_application
          )
        end

        def update
          update_and_advance(SelfAssessmentTaxBillForm, record: current_crime_application.income, as: :client_self_assessment_tax_bill)
        end
      end
    end
  end
end
