module Steps
  module Income
    module Client
      class OtherWorkBenefitsController < Steps::IncomeStepController
        def edit
          @form_object = form_name.build(
            current_crime_application
          )
        end

        def update
          update_and_advance(form_name, as: advance_as)
        end

        private

        def advance_as
          :client_other_work_benefits
        end

        def form_name
          Steps::Income::Client::OtherWorkBenefitsForm
        end
      end
    end
  end
end
