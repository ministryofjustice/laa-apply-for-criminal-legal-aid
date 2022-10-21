module Steps
  module Submission
    class DeclarationController < Steps::SubmissionStepController
      def edit
        @form_object = DeclarationForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(DeclarationForm, as: :declaration)
      end
    end
  end
end
