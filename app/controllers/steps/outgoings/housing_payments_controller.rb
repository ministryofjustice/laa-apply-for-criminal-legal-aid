module Steps
  module Outgoings
    class HousingPaymentsController < Steps::OutgoingsStepController
      include AmountAndFrequency

      before_action :set_payment_type

      def edit
        @form_object = HousingPaymentForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HousingPaymentForm, as: :housing_payment)
      end

      private

      def set_payment_type
        payment_type = outgoings.housing_payment_type

        redirect_to steps_housing_payment_type_path(current_crime_application) if payment_type.nil?

        
        @payment_type = payment_type
      end
    end
  end
end
