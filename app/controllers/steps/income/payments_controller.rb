module Steps
  module Income
    class PaymentsController < Steps::IncomeStepController
      def edit
        @form_object = PaymentsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PaymentsForm, as: :payments)
      end
    end
  end
end
