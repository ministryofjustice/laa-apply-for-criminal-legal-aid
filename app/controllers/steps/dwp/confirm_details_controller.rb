module Steps
  module Dwp
    class ConfirmDetailsController < Steps::DwpStepController
      def edit
        @form_object = ConfirmDetailsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(ConfirmDetailsForm, as: :confirm_details)
      end
    end
  end
end
