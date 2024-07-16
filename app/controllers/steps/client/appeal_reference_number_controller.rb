module Steps
  module Client
    class AppealReferenceNumberController < Steps::ClientStepController
      before_action :redirect_cifc

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
