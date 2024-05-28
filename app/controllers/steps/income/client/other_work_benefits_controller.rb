module Steps
  module Income
    module Client
      class OtherWorkBenefitsController < Steps::IncomeStepController
        def edit
          @form_object = OtherWorkBenefitsForm.build(
            current_crime_application
          )
        end

        def update
          update_and_advance(OtherWorkBenefitsForm, as: :client_other_work_benefits)
        end
      end
    end
  end
end
