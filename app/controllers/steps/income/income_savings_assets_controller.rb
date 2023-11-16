module Steps
  module Income
    class IncomeSavingsAssetsController < Steps::IncomeStepController
      def edit
        @form_object = IncomeSavingsAssetsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(IncomeSavingsAssetsForm, as: :income_savings_assets)
      end
    end
  end
end
