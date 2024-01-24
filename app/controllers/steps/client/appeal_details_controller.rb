module Steps
  module Client
    class AppealDetailsController < Steps::ClientStepController
      def edit
        @form_object = AppealDetailsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(AppealDetailsForm, as: :appeal_details)
      end
    end
  end
end
