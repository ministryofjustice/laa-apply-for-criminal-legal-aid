module Steps
  module Income
    module Client
      module EmploymentUpdateStep
        extend ActiveSupport::Concern

        def edit
          @form_object = form_name.build(
            employment_record, crime_application: current_crime_application
          )
        end

        def update
          update_and_advance(
            form_name, record: employment_record, as: advance_as, flash: flash_msg
          )
        end

        def confirm_destroy
          @employment = employment_record
        end

        def destroy
          employment_record.destroy

          if employments.reload.any?
            redirect_to edit_steps_income_client_employments_summary_path, success: t('.success_flash')
          else
            redirect_to edit_steps_income_employment_status_path, success: t('.success_flash')
          end
        end

        private

        def employment_record
          @employment_record ||= employments.find(params[:employment_id])
        rescue ActiveRecord::RecordNotFound
          raise Errors::EmploymentNotFound
        end

        def employments
          @employments ||= current_crime_application.employments
        end

        # :nocov:
        def advance_as
          raise NotImplementedError
        end

        def form_name
          raise NotImplementedError
        end

        def flash_msg
          nil
        end
        # :nocov:
      end
    end
  end
end
