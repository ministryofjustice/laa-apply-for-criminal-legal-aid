module Steps
  module Income
    module Client
      class EmploymentsSummaryController < Steps::IncomeStepController
        before_action :require_employment

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

        def require_employment
          return true if current_crime_application.employments.present?

          redirect_to edit_steps_income_employment_status_path(current_crime_application)
        end
      end
    end
  end
end
