module Steps
  module Income
    class IncomePaymentsPartnerController < Steps::IncomeStepController
      def edit
        @form_object = Steps::Income::Partner::IncomePaymentsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          Steps::Income::Partner::IncomePaymentsForm, as: :income_payments_partner
        )
      end

      def additional_permitted_params
        payment_types = IncomePaymentType::OTHER_INCOME_PAYMENT_TYPES.map(&:to_s)
        fieldset_attributes = Steps::Income::Partner::IncomePaymentFieldsetForm.attribute_names

        [
          payment_types.product([fieldset_attributes]).to_h.merge('types' => [], 'income_payments' => [])
        ]
      end
    end
  end
end
