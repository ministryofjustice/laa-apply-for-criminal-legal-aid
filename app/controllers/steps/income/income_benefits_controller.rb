module Steps
  module Income
    class IncomeBenefitsController < Steps::IncomeStepController
      def edit
        @form_object = IncomeBenefitsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          IncomeBenefitsForm, as: :income_benefits
        )
      end

      def additional_permitted_params
        payment_types = IncomeBenefitType.values.map(&:to_s)
        fieldset_attributes = Steps::Income::IncomeBenefitFieldsetForm.attribute_names + ['amount_in_pounds']

        [
          payment_types.product([fieldset_attributes]).to_h.merge('types' => [], 'benefit_payments' => [])
        ]
      end
    end
  end
end
