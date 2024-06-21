module Steps
  module Income
    module Partner
      class EmploymentDetailsController < Steps::Income::Client::EmploymentDetailsController
        def advance_as
          :partner_employment_details
        end

        def form_name
          Steps::Income::Partner::EmploymentDetailsForm
        end

        def employments
          @employments ||= current_crime_application.partner_employments
        end
      end
    end
  end
end
