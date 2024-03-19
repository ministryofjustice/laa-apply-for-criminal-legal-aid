module Steps
  module Outgoings
    class BoardAndLodgingController < Steps::OutgoingsStepController
      before_action :editable?, only: :edit

      def edit
        @form_object = BoardAndLodgingForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(BoardAndLodgingForm, as: :board_and_lodging)
      end

      def editable?
        return true if current_housing_payment_type == HousingPaymentType::BOARD_AND_LODGING.to_s

        redirect_to edit_steps_outgoings_housing_payment_type_path
      end
    end
  end
end
