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
        [(IncomePaymentType.values.map { |t| [t.to_s, Steps::Income::IncomePaymentFieldsetForm.attribute_names] } + [['income_payment', []]]).to_h]
      end
    end
  end
end
