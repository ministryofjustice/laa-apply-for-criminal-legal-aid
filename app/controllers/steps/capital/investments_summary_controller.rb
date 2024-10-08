module Steps
  module Capital
    class InvestmentsSummaryController < Steps::CapitalStepController
      before_action :require_investments

      def edit
        @form_object = InvestmentsSummaryForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(InvestmentsSummaryForm, as: :investments_summary)
      end

      private

      def additional_permitted_params
        [:add_investment]
      end

      def require_investments
        return true if current_crime_application.capital.investments.present?

        redirect_to edit_steps_capital_investment_type_path(current_crime_application)
      end
    end
  end
end
