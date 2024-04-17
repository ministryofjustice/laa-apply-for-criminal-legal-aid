module Steps
  module Client
    class AppealReferenceNumberController < Steps::ClientStepController
      def edit
        @form_object = AppealReferenceNumberForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(AppealReferenceNumberForm, as: :appeal_reference_number)
      end
    end
  end
end
