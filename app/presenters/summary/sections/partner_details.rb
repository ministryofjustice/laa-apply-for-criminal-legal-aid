module Summary
  module Sections
    class PartnerDetails < Sections::BaseSection
      def show?
        partner.present? && client.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
          Components::ValueAnswer.new(
            :relationship_to_partner, client.relationship_to_partner,
            change_path: edit_steps_partner_relationship_path
          ),
          Components::FreeTextAnswer.new(
            :first_name, partner.first_name,
            change_path: edit_steps_partner_details_path
          ),
          Components::FreeTextAnswer.new(
            :last_name, partner.last_name,
            change_path: edit_steps_partner_details_path
          ),
          Components::FreeTextAnswer.new(
            :other_names, partner.other_names,
            change_path: edit_steps_partner_details_path, show: true,
          ),
          Components::DateAnswer.new(
            :date_of_birth, partner.date_of_birth,
            change_path: edit_steps_partner_details_path
          ),
          Components::FreeTextAnswer.new(
            :nino, partner.nino,
            change_path: edit_steps_partner_nino_path, show: true,
          ),
          Components::ValueAnswer.new(
            :involvement_in_case, partner.involvement_in_case,
            change_path: edit_steps_partner_involvement_path
          ),
          Components::ValueAnswer.new(
            :conflict_of_interest, partner.conflict_of_interest,
            change_path: edit_steps_partner_conflict_path
          ),
          Components::ValueAnswer.new(
            :has_same_address_as_client, partner.has_same_address_as_client,
            change_path: edit_steps_partner_same_address_path
          ),
          Components::FreeTextAnswer.new(
            :home_address, partner_home_address,
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def partner
        @partner ||= crime_application.partner
      end

      def client
        @client ||= crime_application.applicant
      end

      def partner_home_address
        address = partner&.home_address
        return unless address

        address.attributes.symbolize_keys.slice(*Address::ADDRESS_ATTRIBUTES).values.compact_blank.join("\r\n")
      end
    end
  end
end
