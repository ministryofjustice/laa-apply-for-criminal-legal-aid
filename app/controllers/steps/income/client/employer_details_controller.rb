module Steps
  module Income
    module Client
      class EmployerDetailsController < Steps::IncomeStepController
        include Steps::Income::EmploymentUpdateStep

        def advance_as
          :client_employer_details
        end

        def form_name
          Steps::Income::Client::EmployerDetailsForm
        end

        private

        def employments
          @employments ||= current_crime_application.client_employments
        end

        def additional_permitted_params
          [{ address: [:address_line_one, :address_line_two, :city, :country, :postcode] }]
        end
      end
    end
  end
end
