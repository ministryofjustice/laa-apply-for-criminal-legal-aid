module Steps
  module DWP
    class ConfirmResultController < Steps::DWPStepController
      def edit
        @form_object = form.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(form, as: :confirm_result)
      end

      def form
        benefit_check_on_partner? ? ConfirmResultPartnerForm : ConfirmResultForm
      end
    end
  end
end
