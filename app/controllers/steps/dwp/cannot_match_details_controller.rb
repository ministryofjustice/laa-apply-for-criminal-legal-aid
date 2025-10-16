module Steps
  module DWP
    class CannotMatchDetailsController < Steps::DWPStepController
      def edit
        @form_object = CannotMatchDetailsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(CannotMatchDetailsForm, as: :cannot_match_details)
      end
    end
  end
end
