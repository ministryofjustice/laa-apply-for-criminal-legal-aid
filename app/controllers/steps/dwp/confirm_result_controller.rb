module Steps
  module Dwp
    class ConfirmResultController < Steps::DwpStepController
      def edit
        @form_object = ConfirmResultForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(ConfirmResultForm, as: :confirm_result)
      end
    end
  end
end
