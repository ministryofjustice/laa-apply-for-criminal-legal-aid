module Steps
  module Submission
    class MoreInformationController < Steps::SubmissionStepController
      def edit
        @form_object = MoreInformationForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(MoreInformationForm, as: :more_information)
      end
    end
  end
end
