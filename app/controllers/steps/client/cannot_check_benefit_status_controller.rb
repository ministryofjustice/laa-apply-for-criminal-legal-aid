module Steps
  module Client
    class CannotCheckBenefitStatusController < Steps::ClientStepController
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
