module Steps
  module DWP
    class PartnerConfirmResultController < Steps::DWPStepController
      def edit
        @form_object = PartnerConfirmResultForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PartnerConfirmResultForm, as: :partner_confirm_result)
      end
    end
  end
end
