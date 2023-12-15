module Steps
  module Outgoings
    class OutgoingsMoreThanIncomeController < Steps::OutgoingsStepController
      def edit
        @form_object = OutgoingsMoreThanIncomeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(OutgoingsMoreThanIncomeForm, as: :outgoings_more_than_income)
      end
    end
  end
end
