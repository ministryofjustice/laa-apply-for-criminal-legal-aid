module Steps
  module Client
    class BenefitTypeController < Steps::ClientStepController
      def edit
        @form_object = BenefitTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(BenefitTypeForm, as: :benefit_type)
      end
    end
  end
end
