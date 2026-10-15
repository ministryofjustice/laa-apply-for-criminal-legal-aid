module Steps
  module Income
    module Client
      class SelfAssessmentTaxBillPaymentController < Steps::IncomeStepController
        def edit
          @form_object = SelfAssessmentTaxBillPaymentForm.build(current_crime_application)
        end

        def update
          update_and_advance(SelfAssessmentTaxBillPaymentForm, as: :client_self_assessment_tax_bill_payment)
        end
      end
    end
  end
end
