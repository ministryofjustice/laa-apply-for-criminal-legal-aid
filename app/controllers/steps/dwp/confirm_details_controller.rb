module Steps
  module DWP
    class ConfirmDetailsController < Steps::DWPStepController
      before_action :set_presenter

      def edit
        @form_object = ConfirmDetailsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(ConfirmDetailsForm, as: :confirm_details)
      end

      private

      def set_presenter
        @client_details = Summary::Sections::ClientDetails.new(
          current_crime_application, editable: false, headless: true
        )
      end
    end
  end
end
