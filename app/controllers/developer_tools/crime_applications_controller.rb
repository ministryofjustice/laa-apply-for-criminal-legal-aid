# :nocov:
module DeveloperTools
  class CrimeApplicationsController < ApplicationController
    def destroy
      current_crime_application.destroy

      redirect_to crime_applications_path, flash: { success: 'Application has been deleted' }
    end

    def mark_as_returned
      DatastoreApi::Requests::UpdateApplication.new(
        application_id: application_id,
        member: :return,
        payload: {
          return_details: {
            reason: :provider_request,
            details: 'Application returned through Apply developer tools.',
          }
        }
      ).call

      redirect_to completed_crime_applications_path(q: :returned),
                  flash: { success: 'Application marked as returned' }
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

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def under18_bypass
      find_or_create_applicant(
        dob: rand(15..17).years.ago,
        nino: nil,
        passporting_benefit: nil,
      ).update(
        correspondence_address_type: CorrespondenceType::PROVIDERS_OFFICE_ADDRESS,
        telephone_number: '123456789',
      )

      find_or_create_case

      crime_application.update(
        client_has_partner: YesNoAnswer::NO,
        navigation_stack: [
          edit_steps_client_has_partner_path(crime_application),
          edit_steps_client_details_path(crime_application),
          edit_steps_client_contact_details_path(crime_application),
          edit_steps_case_urn_path(crime_application),
          edit_steps_case_case_type_path(crime_application),
        ]
      )

      redirect_to edit_steps_case_case_type_path(crime_application)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def crime_application
      @crime_application ||= current_crime_application || initialize_crime_application(
        client_has_partner: YesNoAnswer::NO,
      )
    end

    def find_or_create_applicant(overrides = {})
      Applicant.find_or_initialize_by(crime_application_id: crime_application.id).tap do |record|
        surname, details = DWP::MockBenefitCheckService::KNOWN.to_a.sample

        record.update(
          first_name: record.first_name || 'Test',
          last_name: surname,
          other_names: '',
          date_of_birth: overrides.fetch(:dob, details[:dob]),
          nino: overrides.fetch(:nino, details[:nino]),
          passporting_benefit: overrides.fetch(:dwp, true),
        )
      end
    end

    def find_or_create_case
      Case.find_or_initialize_by(crime_application_id: crime_application.id).tap do |record|
        record.update(
          urn: '',
        )
      end
    end
  end
end
# :nocov:
