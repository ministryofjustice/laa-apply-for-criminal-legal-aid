module Steps
  module Income
    class ManageWithoutIncomeController < Steps::IncomeStepController
      def edit
        @form_object = ManageWithoutIncomeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ManageWithoutIncomeForm, as: :manage_without_income)
      end
    end
  end
end
