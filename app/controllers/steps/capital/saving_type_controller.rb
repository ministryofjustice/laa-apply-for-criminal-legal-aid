module Steps
  module Capital
    class SavingTypeController < Steps::CapitalStepController
      before_action :require_no_savings

      def edit
        @form_object = SavingTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(SavingTypeForm, as: :saving_type)
      end

      private

      def additional_permitted_params
        [:saving_type]
      end

      def require_no_savings
        # pp current_crime_application.capital.savings
        return true if current_crime_application.capital.savings.empty?

        redirect_to edit_steps_capital_savings_summary_path(current_crime_application)
      end
    end
  end
end
