module Steps
  module Capital
    class FrozenIncomeSavingsAssetsController < Steps::CapitalStepController
      def edit
        @form_object = FrozenIncomeSavingsAssetsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(FrozenIncomeSavingsAssetsForm, as: :frozen_income_savings_assets)
      end
    end
  end
end
