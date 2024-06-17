module Steps
  module Income
    module Partner
      module EmploymentUpdateStep
        include Steps::Income::EmploymentUpdateStep

        def destroy
          employment_record.destroy

          if employments.reload.any?
            redirect_to edit_steps_income_partner_employments_summary_path, success: t('.success_flash')
          else
            redirect_to edit_steps_income_partner_employment_status_path, success: t('.success_flash')
          end
        end

        private

        def employments
          @employments ||= current_crime_application.partner_employments
        end
      end
    end
  end
end
