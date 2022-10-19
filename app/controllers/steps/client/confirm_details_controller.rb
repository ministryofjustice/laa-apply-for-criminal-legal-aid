module Steps
  module Client
    class ConfirmDetailsController < Steps::ClientStepController
      def edit
        @form_object = ConfirmDetailsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ConfirmDetailsForm, as: :confirm_details)
      end

      private

      def additional_permitted_params
        %i[confirm_details]
      end
    end
  end
end
