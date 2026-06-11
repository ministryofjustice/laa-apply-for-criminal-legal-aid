module Steps
  module Capital
    class FrozenIncomeOrAssetsSubjectController < Steps::CapitalStepController
      def edit
        @form_object = FrozenIncomeOrAssetsSubjectForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(FrozenIncomeOrAssetsSubjectForm, as: :frozen_income_or_assets_subject)
      end
    end
  end
end
