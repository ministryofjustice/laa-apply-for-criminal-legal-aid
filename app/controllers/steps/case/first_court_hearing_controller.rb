module Steps
  module Case
    class FirstCourtHearingController < Steps::CaseStepController
      before_action :redirect_cifc

      def edit
        @form_object = FirstCourtHearingForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(FirstCourtHearingForm, as: :first_court_hearing)
      end
    end
  end
end
