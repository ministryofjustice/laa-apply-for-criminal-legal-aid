module Steps
  module DWP
    class CannotCheckBenefitStatusController < Steps::DWPStepController
      def edit
        @form_object = CannotCheckBenefitStatusForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(CannotCheckBenefitStatusForm, as: :cannot_check_benefit_status)
      end
    end
  end
end
