module Steps
  module Income
    module Client
      class EmploymentsController < Steps::IncomeStepController
        include Steps::Income::EmploymentUpdateStep

        def destroy
          employment_record.destroy

          if employments.reload.any?
            redirect_to edit_steps_income_client_employments_summary_path, success: t('.success_flash')
          else
            redirect_to edit_steps_income_employment_status_path, success: t('.success_flash')
          end
        end

        def confirm_destroy
          @employment = employment_record
        end

        private

        def employments
          @employments ||= current_crime_application.employments
        end
      end
    end
  end
end
