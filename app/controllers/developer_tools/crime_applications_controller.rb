# :nocov:
module DeveloperTools
  class CrimeApplicationsController < ApplicationController
    def destroy
      if current_crime_application
        current_crime_application.destroy
      elsif current_remote_application
        DatastoreApi::Requests::DeleteApplication.new(
          application_id: params[:id]
        ).call
      end

      redirect_to crime_applications_path, flash: { success: 'Application has been deleted' }
    end

    def mark_as_returned
      DatastoreApi::Requests::UpdateApplication.new(
        application_id: params[:id],
        payload: { status: ApplicationStatus::RETURNED }
      ).call

      redirect_to crime_applications_path, flash: { success: 'Application marked as returned' }
    end

    def bypass_dwp
      find_or_create_applicant

      crime_application.update(
        client_has_partner: YesNoAnswer::NO,
        navigation_stack: [
          edit_steps_client_has_partner_path(crime_application),
          edit_steps_client_details_path(crime_application),
          edit_steps_client_has_nino_path(crime_application),
          edit_steps_client_benefit_check_result_path(crime_application),
        ]
      )

      redirect_to edit_steps_client_benefit_check_result_path(crime_application)
    end

    private

    # For developer tools we don't do any scoping by provider/firm
    def current_crime_application
      @current_crime_application ||= CrimeApplication.in_progress.find_by(id: params[:id])
    end

    def current_remote_application
      @current_remote_application ||= DatastoreApi::Requests::GetApplication.new(
        application_id: params[:id]
      ).call
    end

    def crime_application
      @crime_application ||= current_crime_application || initialize_crime_application(
        client_has_partner: YesNoAnswer::NO,
      )
    end

    def find_or_create_applicant
      Applicant.find_or_initialize_by(crime_application_id: crime_application.id).tap do |record|
        surname, details = DWP::MockBenefitCheckService::KNOWN.to_a.sample

        record.update(
          first_name: record.first_name || 'Test',
          last_name: surname,
          other_names: '',
          date_of_birth: details[:dob],
          has_nino: YesNoAnswer::YES,
          nino: details[:nino],
          passporting_benefit: true,
        )
      end
    end
  end
end
# :nocov:
