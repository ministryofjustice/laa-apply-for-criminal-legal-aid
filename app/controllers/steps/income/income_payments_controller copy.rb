module Steps
  module Income
    class BenefitPaymentsController < Steps::IncomeStepController
      def edit
        @form_object = BenefitPaymentsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BenefitPaymentsForm, as: :benefit_payments
        )
      end

      def additional_permitted_params
        payment_types = BenefitPaymentType.values.map(&:to_s)
        fieldset_attributes = Steps::Income::BenefitPaymentFieldsetForm.attribute_names + ['amount_in_pounds']

        [
          payment_types.product([fieldset_attributes]).to_h.merge('types' => [], 'benefit_payments' => [])
        ]
      end
    end
  end
end
