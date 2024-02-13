module Steps
  module Income
    class IncomePaymentsController < Steps::IncomeStepController
      def edit
        @form_object = IncomePaymentsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          IncomePaymentsForm, as: :income_payments
        )
      end

      def additional_permitted_params
        payment_types = IncomePaymentType.values.map(&:to_s)
        fieldset_attributes = Steps::Income::IncomePaymentFieldsetForm.attribute_names + ['amount_in_pounds']

        [
          payment_types.product([fieldset_attributes]).to_h.merge('types' => [], 'income_payments' => [])
        ]
      end
    end
  end
end
