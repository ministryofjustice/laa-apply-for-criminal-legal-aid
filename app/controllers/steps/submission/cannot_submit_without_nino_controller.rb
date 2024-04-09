module Steps
  module Submission
    class CannotSubmitWithoutNinoController < Steps::SubmissionStepController
      def edit
        @form_object = CannotSubmitWithoutNinoForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(CannotSubmitWithoutNinoForm, as: :cannot_submit_without_nino)
      end
    end
  end
end
