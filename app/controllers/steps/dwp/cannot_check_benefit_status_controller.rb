module Steps
  module DWP
    class CannotCheckBenefitStatusController < Steps::DWPStepController
      def edit
        @form_object = form.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(form, as: :cannot_check_benefit_status)
      end

      private

      def form
        benefit_check_on_partner? ? CannotCheckBenefitStatusPartnerForm : CannotCheckBenefitStatusForm
      end
    end
  end
end
