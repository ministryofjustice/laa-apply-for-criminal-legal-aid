module Steps
  module Income
    module Partner
      class SelfAssessmentTaxBillPaymentController < Steps::IncomeStepController
        before_action :require_self_assessment_tax_bill

        def edit
          @form_object = SelfAssessmentTaxBillPaymentForm.build(current_crime_application)
        end

        def update
          update_and_advance(SelfAssessmentTaxBillPaymentForm, as: :partner_self_assessment_tax_bill_payment)
        end

        private

        def require_self_assessment_tax_bill
          return if current_crime_application.income&.partner_self_assessment_tax_bill == YesNoAnswer::YES.to_s

          redirect_to edit_steps_income_partner_self_assessment_tax_bill_path(current_crime_application)
        end
      end
    end
  end
end
