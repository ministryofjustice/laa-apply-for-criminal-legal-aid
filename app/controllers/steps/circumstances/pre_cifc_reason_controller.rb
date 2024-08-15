module Steps
  module Circumstances
    class PreCifcReasonController < Steps::CircumstancesStepController
      def edit
        @form_object = PreCifcReasonForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PreCifcReasonForm, as: :pre_cifc_reason)
      end
    end
  end
end
