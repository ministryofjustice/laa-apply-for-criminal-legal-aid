module Steps
  module Capital
    class OtherInvestmentTypeController < Steps::CapitalStepController
      def edit
        @form_object = OtherInvestmentTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(OtherInvestmentTypeForm, as: :investment_type)
      end

      private

      def additional_permitted_params
        [:investment_type]
      end
    end
  end
end
