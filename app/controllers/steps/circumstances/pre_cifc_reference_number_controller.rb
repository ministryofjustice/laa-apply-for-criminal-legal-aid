module Steps
  module Circumstances
    class PreCifcReferenceNumberController < Steps::CircumstancesStepController
      def edit
        @form_object = PreCifcReferenceNumberForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PreCifcReferenceNumberForm, as: :pre_cifc_reference_number)
      end
    end
  end
end
