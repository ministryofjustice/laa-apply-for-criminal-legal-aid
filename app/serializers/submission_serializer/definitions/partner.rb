module SubmissionSerializer
  module Definitions
    class Partner < Definitions::BaseDefinition
      def present?
        super && partner.present?
      end

      # rubocop:disable Metrics/AbcSize
      def to_builder
        Jbuilder.new do |json|
          json.first_name partner.first_name
          json.last_name partner.last_name
          json.other_names partner.other_names
          json.date_of_birth partner.date_of_birth
          json.home_address Definitions::Address.generate(partner.home_address)

          json.has_nino partner.has_nino
          json.nino partner.nino

          json.involvement_in_case partner_detail.involvement_in_case
          json.conflict_of_interest partner_detail.conflict_of_interest
          json.has_same_address_as_client partner_detail.has_same_address_as_client
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
