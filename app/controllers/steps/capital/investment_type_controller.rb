module Steps
  module Capital
    class InvestmentTypeController < Steps::CapitalStepController
      before_action :require_no_investments

      def edit
        @form_object = InvestmentTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(InvestmentTypeForm, as: :investment_type)
      end

      private

      def additional_permitted_params
        [:investment_type]
      end

      def require_no_investments
        return true if current_crime_application.capital.investments.empty?

        redirect_to edit_steps_capital_investments_summary_path(current_crime_application)
      end
    end
  end
end
