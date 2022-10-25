module Steps
  module Client
    class BenefitCheckResultController < Steps::ClientStepController
      def edit
        @form_object = BenefitCheckResultForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(BenefitCheckResultForm, as: :benefit_check_result)
      end
    end
  end
end
