module Steps
  module DWP
    class ConfirmDetailsController < Steps::DWPStepController
      before_action :set_presenter

      def edit
        @form_object = ConfirmDetailsForm.build(current_crime_application)
      end

      def update
        update_and_advance(ConfirmDetailsForm, as: :confirm_details)
      end

      private

      def set_presenter
        @dwp_client_details = [Summary::Sections::DWPClientDetails.new(
          current_crime_application, editable: false, headless: true
        )].select(&:show?)
      end
    end
  end
end
