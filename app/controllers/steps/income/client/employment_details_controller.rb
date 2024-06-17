module Steps
  module Income
    module Client
      class EmploymentDetailsController < Steps::IncomeStepController
        include Steps::Income::EmploymentUpdateStep

        def advance_as
          :client_employment_details
        end

        def employments
          @employments ||= current_crime_application.client_employments
        end

        def form_name
          EmploymentDetailsForm
        end
      end
    end
  end
end
