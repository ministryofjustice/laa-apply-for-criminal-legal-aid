module SubmissionSerializer
  module Definitions
    class Partner < Definitions::BaseDefinition
      def present?
        super && partner.present?
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def to_builder
        Jbuilder.new do |json|
          json.first_name partner.first_name
          json.last_name partner.last_name
          json.other_names partner.other_names
          json.date_of_birth partner.date_of_birth
          json.home_address Definitions::Address.generate(partner.home_address)

          json.has_nino partner.has_nino
          json.nino partner.nino

          json.benefit_type partner.benefit_type
          json.last_jsa_appointment_date partner.last_jsa_appointment_date
          json.benefit_check_result partner.benefit_check_result
          json.will_enter_nino partner.will_enter_nino
          json.has_benefit_evidence partner.has_benefit_evidence
          json.confirm_details partner.confirm_details
          json.confirm_dwp_result partner.confirm_dwp_result
          json.benefit_check_status DWP::BenefitCheckStatusService.call(self, partner)

          json.involvement_in_case partner_detail.involvement_in_case
          json.conflict_of_interest partner_detail.conflict_of_interest
          json.has_same_address_as_client partner_detail.has_same_address_as_client

          json.is_included_in_means_assessment is_included_in_means_assessment
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      # TODO: how to include TypeOfMeansAssessment in this file??
      def is_included_in_means_assessment
        return false unless partner.present? || partner_detail.present?
        return true if partner_involvement_in_case == PartnerInvolvementType::NONE.to_s
        return false unless partner_involvement_in_case == PartnerInvolvementType::CODEFENDANT.to_s

        partner_conflict_of_interest == 'no'
      end
    end
  end
end
