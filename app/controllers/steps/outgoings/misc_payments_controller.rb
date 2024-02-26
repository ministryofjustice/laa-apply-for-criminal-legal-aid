module Steps
  module Outgoings
    class MiscPaymentsController < Steps::OutgoingsStepController
      def edit
        @form_object = MiscPaymentsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          MiscPaymentsForm, as: :misc_payments
        )
      end

      def additional_permitted_params
        payment_types = OutgoingsPaymentType::MISC_PAYMENT_TYPES.map(&:to_s)
        fieldset_attributes = Steps::Outgoings::MiscPaymentFieldsetForm.attribute_names

        [
          payment_types.product([fieldset_attributes]).to_h.merge('types' => [], 'misc_payments' => [])
        ]
      end
    end
  end
end
