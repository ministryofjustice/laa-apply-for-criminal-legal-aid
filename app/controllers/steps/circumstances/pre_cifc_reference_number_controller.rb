module Steps
  module Circumstances
    class PreCifcReferenceNumberController < Steps::CircumstancesStepController
      before_action :redirect_non_cifc

      def edit
        @form_object = PreCifcReferenceNumberForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PreCifcReferenceNumberForm, as: :pre_cifc_reference_number)
      end

      private

      def redirect_non_cifc
        return unless FeatureFlags.cifc_journey.enabled?

        redirect_to edit_crime_application_path(current_crime_application) unless current_crime_application.cifc?
      end
    end
  end
end
