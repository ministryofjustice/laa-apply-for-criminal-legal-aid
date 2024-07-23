module Steps
  module Case
    class ChargesSummaryController < Steps::CaseStepController
      before_action :redirect_cifc

      def edit
        @form_object = ChargesSummaryForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(ChargesSummaryForm, as: :charges_summary)
      end
    end
  end
end
