module Steps
  module DWP
    class ConfirmDetailsController < Steps::DWPStepController
      before_action :set_presenter

      def edit
        @form_object = form.build(current_crime_application)
      end

      def update
        update_and_advance(form, as: :confirm_details)
      end

      private

      def set_presenter
        @dwp_details = [Summary::Sections::DWPDetails.new(
          current_crime_application, editable: false, headless: true
        )].select(&:show?)
      end

      def form
        benefit_check_on_partner? ? ConfirmPartnerDetailsForm : ConfirmDetailsForm
      end
    end
  end
end
