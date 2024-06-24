module Steps
  module Income
    module Partner
      class EmployerDetailsController < Steps::Income::Client::EmployerDetailsController
        def advance_as
          :partner_employer_details
        end

        def form_name
          Steps::Income::Partner::EmployerDetailsForm
        end

        def employments
          @employments ||= current_crime_application.partner_employments
        end
      end
    end
  end
end
