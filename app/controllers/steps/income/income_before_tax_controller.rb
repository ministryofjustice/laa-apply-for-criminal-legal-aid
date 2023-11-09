module Steps
  module Income
    class IncomeBeforeTaxController < Steps::IncomeStepController
      def edit
        @form_object = IncomeBeforeTaxForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(IncomeBeforeTaxForm, as: :income_before_tax)
      end
    end
  end
end
