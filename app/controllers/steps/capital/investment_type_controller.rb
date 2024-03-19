module Steps
  module Capital
    class InvestmentTypeController < Steps::CapitalStepController
      def edit
        @form_object = InvestmentTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(InvestmentTypeForm, as: :investment_type)
      end

      def additional_permitted_params
        [:investment_type]
      end
    end
  end
end
