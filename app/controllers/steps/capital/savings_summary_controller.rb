module Steps
  module Capital
    class SavingsSummaryController < Steps::CapitalStepController
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
    end
  end
end
