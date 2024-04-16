module Steps
  module Client
    class AppealFinancialCircumstancesController < Steps::ClientStepController
      def edit
        @form_object = AppealFinancialCircumstancesForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(AppealFinancialCircumstancesForm, as: :appeal_financial_circumstances)
      end
    end
  end
end
