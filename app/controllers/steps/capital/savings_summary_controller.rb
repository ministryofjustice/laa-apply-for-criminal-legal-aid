module Steps
  module Capital
    class SavingsSummaryController < Steps::CapitalStepController
      before_action :require_savings

      def edit
        @form_object = SavingsSummaryForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(SavingsSummaryForm, as: :savings_summary)
      end

      private

      def additional_permitted_params
        [:add_saving]
      end

      def require_savings
        return true if current_crime_application.capital.savings.present?

        redirect_to edit_steps_capital_saving_type_path(current_crime_application)
      end
    end
  end
end
