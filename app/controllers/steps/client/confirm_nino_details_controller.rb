module Steps
  module Client
    class ConfirmNinoDetailsController < Steps::ClientStepController
      def edit
        @form_object = ConfirmNinoDetailsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ConfirmNinoDetailsForm, as: :confirm_nino_details)
      end

      private

      def additional_permitted_params
        %i[confirm_nino_details]
      end
    end
  end
end
