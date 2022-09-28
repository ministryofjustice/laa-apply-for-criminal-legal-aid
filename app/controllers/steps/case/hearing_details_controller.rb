module Steps
  module Case
    class HearingDetailsController < Steps::CaseStepController
      def edit
        @form_object = HearingDetailsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HearingDetailsForm, as: :hearing_details)
      end
    end
  end
end
