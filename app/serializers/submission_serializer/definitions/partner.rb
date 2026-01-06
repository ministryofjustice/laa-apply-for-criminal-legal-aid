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

          json.has_nino partner.has_nino
          json.has_arc partner.has_arc
          json.nino partner.nino
          json.arc partner.arc

          json.involvement_in_case partner_detail.involvement_in_case
          json.conflict_of_interest partner_detail.conflict_of_interest

          if MeansStatus.include_partner?(self)
            json.benefit_type partner.benefit_type
            json.last_jsa_appointment_date partner.last_jsa_appointment_date
            json.benefit_check_result partner.benefit_check_result
            json.will_enter_nino partner.will_enter_nino
            json.has_benefit_evidence partner.has_benefit_evidence
            json.confirm_details partner.confirm_details
            json.confirm_dwp_result partner.confirm_dwp_result
            json.benefit_check_status DWP::BenefitCheckStatusService.call(self, partner)
            json.has_same_address_as_client partner_detail.has_same_address_as_client
            json.home_address Definitions::Address.generate(partner.home_address)
            json.dwp_response partner.dwp_response
          end

          json.is_included_in_means_assessment MeansStatus.include_partner?(self)
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
