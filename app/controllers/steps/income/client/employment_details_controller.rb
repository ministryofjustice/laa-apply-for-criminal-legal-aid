module Steps
  module Income
    module Client
      class EmploymentDetailsController < Steps::IncomeStepController
        include Steps::Income::EmploymentUpdateStep

        def advance_as
          :client_employment_details
        end

        def form_name
          Steps::Income::Client::EmploymentDetailsForm
        end

        def employments
          @employments ||= current_crime_application.employments
        end
      end
    end
  end
end
