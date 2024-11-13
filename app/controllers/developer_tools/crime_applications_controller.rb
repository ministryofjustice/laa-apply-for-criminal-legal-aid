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

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def bypass_dwp
      find_or_create_applicant
      find_or_create_partner_detail

      crime_application.update(
        navigation_stack: [
          edit_steps_client_details_path(crime_application),
          edit_steps_client_is_means_tested_path(crime_application),
          edit_steps_client_case_type_path(crime_application),
          edit_steps_client_residence_type_path(crime_application),
          edit_steps_client_contact_details_path(crime_application),
          edit_steps_nino_path(crime_application, subject: 'client'),
          edit_steps_client_has_partner_path(crime_application),
          edit_steps_client_relationship_status_path(crime_application),
          edit_steps_dwp_benefit_type_path(crime_application),
          edit_steps_dwp_benefit_check_result_path(crime_application),
        ]
      )

      redirect_to edit_steps_dwp_benefit_check_result_path(crime_application)
    end

    def under18_bypass
      find_or_create_applicant(
        dob: rand(15..17).years.ago,
        nino: nil,
        will_enter_nino: nil,
        has_benefit_evidence: nil,
        benefit_type: nil,
        last_jsa_appointment_date: nil,
        benefit_check_result: nil,
      ).update(
        correspondence_address_type: CorrespondenceType::PROVIDERS_OFFICE_ADDRESS,
        telephone_number: '123456789',
      )

      find_or_create_case

      crime_application.update(
        navigation_stack: [
          edit_steps_client_details_path(crime_application),
          edit_steps_client_is_means_tested_path(crime_application),
          edit_steps_client_case_type_path(crime_application),
        ]
      )

      redirect_to edit_steps_client_case_type_path(crime_application)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def crime_application
      @crime_application ||= current_crime_application || initialize_crime_application
    end

    def find_or_create_applicant(overrides = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      Applicant.find_or_initialize_by(crime_application_id: crime_application.id).tap do |record|
        surname, details = DWP::MockBenefitCheckService::KNOWN.to_a.sample

        record.update(
          first_name: record.first_name || 'Test',
          last_name: surname,
          other_names: '',
          date_of_birth: overrides.fetch(:dob, details[:dob]),
          has_nino: overrides.fetch(:has_nino, 'yes'),
          nino: overrides.fetch(:nino, details[:nino]),
          has_arc: overrides.fetch(:has_arc, 'no'),
          arc: overrides.fetch(:nino, nil),
          benefit_type: overrides.fetch(:benefit_type, 'universal_credit'),
          last_jsa_appointment_date: overrides.fetch(:last_jsa_appointment_date, nil),
          benefit_check_result: overrides.fetch(:benefit_check_result, true),
          residence_type: overrides.fetch(:residence_type, 'none'),
          correspondence_address_type: CorrespondenceType::PROVIDERS_OFFICE_ADDRESS,
          telephone_number: '123456789',
        )
      end
    end

    def find_or_create_case
      Case.find_or_initialize_by(crime_application_id: crime_application.id)
    end

    def find_or_create_partner_detail(overrides = {})
      PartnerDetail.find_or_initialize_by(crime_application_id: crime_application.id).tap do |record|
        record.update(
          has_partner: overrides.fetch(:has_partner, 'no'),
          relationship_status: overrides.fetch(:relationship_status, 'single'),
        )
      end
    end
  end
end
# :nocov:
