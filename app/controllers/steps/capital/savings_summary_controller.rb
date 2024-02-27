module Steps
  module Capital
    class SavingsSummaryController < Steps::CapitalStepController
      before_action :set_presenter

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

      def set_presenter
        @savings_details = [Summary::Sections::Savings.new(
          current_crime_application, editable: false, headless: true
        )].select(&:show?)
      end
    end
  end
end
