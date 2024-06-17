module Steps
  module Income
    module Partner
      class EmploymentsSummaryController < Steps::Income::Client::EmploymentsSummaryController
        private

        def form_name
          Steps::Income::Partner::EmploymentsSummaryForm
        end

        def advance_as
          :partner_employments_summary
        end

        def additional_permitted_params
          [:add_partner_employment]
        end

        def require_employment
          return true if current_crime_application.partner_employments.present?

          redirect_to edit_steps_income_partner_employment_status_path(current_crime_application)
        end
      end
    end
  end
end
