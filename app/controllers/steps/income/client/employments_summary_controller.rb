module Steps
  module Income
    module Client
      class EmploymentsSummaryController < Steps::IncomeStepController
        def edit
          @form_object = EmploymentsSummaryForm.build(
            current_crime_application
          )
        end

        def update
          update_and_advance(EmploymentsSummaryForm, as: :employments_summary)
        end

        private

        def additional_permitted_params
          [:add_client_employment]
        end
      end
    end
  end
end
