module Steps
  module DWP
    class CannotCheckDWPStatusController < Steps::DWPStepController
      def edit
        @form_object = CannotCheckDWPStatusForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(CannotCheckDWPStatusForm, as: :cannot_check_dwp_status)
      end
    end
  end
end
