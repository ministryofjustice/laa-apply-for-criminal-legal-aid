module Steps
  module Outgoings
    class RentController < Steps::OutgoingsStepController
      before_action :editable?, only: :edit

      def edit
        @form_object = RentForm.build(current_crime_application)
      end

      def update
        update_and_advance(RentForm, as: :rent)
      end

      def editable?
        return true if current_housing_payment_type == HousingPaymentType::RENT.to_s

        redirect_to edit_steps_outgoings_housing_payment_type_path
      end
    end
  end
end
