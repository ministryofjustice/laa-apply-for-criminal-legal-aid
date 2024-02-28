module Steps
  module Outgoings
    class OutgoingsPaymentsController < Steps::OutgoingsStepController
      def edit
        @form_object = OutgoingsPaymentsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          OutgoingsPaymentsForm, as: :outgoings_payments
        )
      end

      def additional_permitted_params
        payment_types = OutgoingsPaymentType::OTHER_PAYMENT_TYPES.map(&:to_s)
        fieldset_attributes = Steps::Outgoings::OutgoingPaymentFieldsetForm.attribute_names

        [
          payment_types.product([fieldset_attributes]).to_h.merge('types' => [], 'outgoings_payments' => [])
        ]
      end
    end
  end
end
