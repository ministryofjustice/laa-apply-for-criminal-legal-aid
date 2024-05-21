module SubmissionSerializer
  module Definitions
    class Applicant < Definitions::BaseDefinition
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def to_builder
        Jbuilder.new do |json|
          json.first_name applicant.first_name
          json.last_name applicant.last_name
          json.other_names applicant.other_names
          json.date_of_birth applicant.date_of_birth
          json.telephone_number applicant.telephone_number
          json.residence_type applicant.residence_type
          json.relationship_to_owner_of_usual_home_address applicant.relationship_to_owner_of_usual_home_address
          json.correspondence_address_type applicant.correspondence_address_type
          json.home_address Definitions::Address.generate(applicant.home_address)
          json.correspondence_address Definitions::Address.generate(applicant.correspondence_address)

          json.has_nino applicant.has_nino
          json.nino applicant.nino
          json.benefit_type applicant.benefit_type
          json.last_jsa_appointment_date applicant.last_jsa_appointment_date
          json.passporting_benefit applicant.passporting_benefit
          json.will_enter_nino applicant.will_enter_nino
          json.has_benefit_evidence applicant.has_benefit_evidence
          json.confirm_details applicant.confirm_details
          json.confirm_dwp_result confirm_dwp_result
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
