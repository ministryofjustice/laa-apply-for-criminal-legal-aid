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
        dwp_details_app = current_crime_application
        dwp_details_app.applicant&.benefit_type = nil

        @client_details = [Summary::Sections::ClientDetails.new(
          dwp_details_app, editable: false, headless: true
        )].select(&:show?)
      end
    end
  end
end
