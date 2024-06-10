module Steps
  module Income
    module Partner
      class IncomeBenefitsController < Steps::IncomeStepController
        def edit
          @form_object = Steps::Income::Partner::IncomeBenefitsForm.new(
            crime_application: current_crime_application
          )
        end

        def update
          update_and_advance(
            Steps::Income::Partner::IncomeBenefitsForm, as: :partner_income_benefits
          )
        end

        def additional_permitted_params
          payment_types = IncomeBenefitType.values.map(&:to_s)
          fieldset_attributes = Steps::Income::Partner::IncomeBenefitFieldsetForm.attribute_names

          [
            payment_types.product([fieldset_attributes]).to_h.merge('types' => [], 'income_benefits' => [])
          ]
        end
      end
    end
  end
end
