module Steps
  module DWP
    class ConfirmResultController < Steps::DWPStepController
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
