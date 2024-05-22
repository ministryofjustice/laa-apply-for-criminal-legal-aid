module Steps
  module Income
    module Client
      class EmploymentsController < Steps::IncomeStepController
        def edit
          @form_object = EmploymentIncomeForm.build(
            current_crime_application
          )
        end

        def update
          update_and_advance(EmploymentIncomeForm, as: :client_employment_income)
        end

        def confirm_destroy
          @employment = employment_record
        end

        def destroy
          employment_record.destroy

          if employments.reload.any?
            redirect_to edit_steps_income_client_employments_summary_path, success: t('.success_flash')
          else
            new_employment = current_crime_application.employments.create!
            redirect_to edit_steps_income_client_employer_details_path(employment_id: new_employment.id), success: t('.success_flash')
          end
        end

        def employment_record
          @employment_record ||= employments.find(params[:employment_id])
        rescue ActiveRecord::RecordNotFound
          raise Errors::EmploymentNotFound
        end

        def employments
          @employments ||= current_crime_application.employments
        end
      end
    end
  end
end
