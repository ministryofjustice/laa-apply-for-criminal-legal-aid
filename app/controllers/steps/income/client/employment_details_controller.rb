module Steps
  module Income
    module Client
      class EmploymentDetailsController < Steps::IncomeStepController
        include Steps::Income::Client::EmploymentUpdateStep

        def advance_as
          :client_employment_details
        end

        def form_name
          EmploymentDetailsForm
        end
      end
    end
  end
end
