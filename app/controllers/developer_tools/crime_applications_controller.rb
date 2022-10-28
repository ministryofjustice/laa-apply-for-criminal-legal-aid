# :nocov:
module DeveloperTools
  class CrimeApplicationsController < ApplicationController
    before_action :check_crime_application_presence

    def destroy
      current_crime_application.destroy
      redirect_to crime_applications_path, flash: { success: 'Application has been deleted' }
    end

    def bypass_dwp
      find_or_create_applicant

      crime_application.update(
        navigation_stack: [
          edit_steps_client_has_partner_path(crime_application),
          edit_steps_client_details_path(crime_application),
          edit_steps_client_has_nino_path(crime_application),
          edit_steps_client_benefit_check_result_path(crime_application),
        ]
      )

      redirect_to edit_steps_client_benefit_check_result_path(crime_application)
    end

    def mark_as_returned
      current_crime_application.returned!
      redirect_to crime_applications_path, flash: { success: 'Application marked as returned' }
    end

    private

    # For developer tools we don't do any scoping, not that
    # it matters once we purge applications anyways
    def current_crime_application
      @current_crime_application ||= CrimeApplication.find_by(id: params[:id])
    end

    def crime_application
      @crime_application ||= current_crime_application || initialize_crime_application(
        client_has_partner: YesNoAnswer::NO,
      )
    end

    def find_or_create_applicant
      Applicant.find_or_initialize_by(crime_application_id: crime_application.id).tap do |record|
        surname, details = MockBenefitCheckService::KNOWN.to_a.sample

        record.update(
          first_name: record.first_name || 'Test',
          last_name: surname,
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
