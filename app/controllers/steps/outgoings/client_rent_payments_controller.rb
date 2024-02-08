module Steps
  module Outgoings
    class ClientRentPaymentsController < Steps::OutgoingsStepController
      def edit
        @form_object = ClientRentPaymentsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ClientRentPaymentsForm, as: :client_rent_payments)
      end

      # private
      #
      # def additional_permitted_params
      #   [:council_tax_amount_in_pounds]
      # end
    end
  end
end
