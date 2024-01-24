module Steps
  module Outgoings
    class HousingPaymentTypeController < Steps::OutgoingsStepController
      def edit
        @form_object = HousingPaymentTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HousingPaymentTypeForm, as: :housing_payment_type)
      end
    end
  end
end
