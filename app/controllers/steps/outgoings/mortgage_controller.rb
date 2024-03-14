module Steps
  module Outgoings
    class MortgageController < Steps::OutgoingsStepController
      before_action :editable?, only: :edit

      def edit
        @form_object = MortgageForm.build(current_crime_application)
      end

      def update
        update_and_advance(MortgageForm, as: :mortgage)
      end

      def editable?
        return true if current_housing_payment_type == HousingPaymentType::MORTGAGE.to_s

        redirect_to edit_steps_outgoings_housing_payment_type_path
      end
    end
  end
end
