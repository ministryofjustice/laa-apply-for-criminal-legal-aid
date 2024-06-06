module Summary
  module Sections
    class PartnerDetails < Sections::BaseSection
      def show?
        show_partner_detail? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
          Components::ValueAnswer.new(
            :relationship_to_partner, partner_detail.relationship_to_partner,
            change_path: edit_steps_partner_relationship_path
          ),
          Components::FreeTextAnswer.new(
            :first_name, partner&.first_name, show: partner.present?,
            change_path: edit_steps_partner_details_path
          ),
          Components::FreeTextAnswer.new(
            :last_name, partner&.last_name, show: partner.present?,
            change_path: edit_steps_partner_details_path
          ),
          Components::FreeTextAnswer.new(
            :other_names, partner&.other_names, show: partner.present?,
            change_path: edit_steps_partner_details_path,
          ),
          Components::DateAnswer.new(
            :date_of_birth, partner&.date_of_birth, show: partner.present?,
            change_path: edit_steps_partner_details_path
          ),
          Components::ValueAnswer.new(
            :involvement_in_case, partner_detail.involvement_in_case,
            change_path: edit_steps_partner_involvement_path
          ),
          Components::ValueAnswer.new(
            :conflict_of_interest, partner_detail.conflict_of_interest,
            change_path: edit_steps_partner_conflict_path
          ),
          Components::ValueAnswer.new(
            :same_address_as_client, partner_detail.same_address_as_client,
            change_path: edit_steps_partner_same_address_path
          ),
          Components::FreeTextAnswer.new(
            :home_address, full_address(home_address), show: home_address.present?,
            change_path: change_path(home_address)
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def partner_detail
        @partner_detail ||= crime_application.partner_detail
      end

      def partner
        @partner ||= partner_detail&.partner
      end

      def show_partner_detail?
        crime_application.partner_detail.present?
      end

      def home_address
        partner&.home_address
      end

      # Copied from contact_details.rb
      def change_path(address)
        return unless address.try(:to_param)

        if address.lookup_id.present?
          # A postcode lookup was performed and an address was selected
          edit_steps_address_results_path(address)
        elsif address.address_line_one.present?
          # Postcode lookup didn't return correct results, failed, or manual address
          edit_steps_address_details_path(address)
        else
          # No address present, we take them to the postcode lookup
          edit_steps_address_lookup_path(address)
        end
      end

      def full_address(address)
        return unless address

        address.values_at(
          *Address::ADDRESS_ATTRIBUTES
        ).compact_blank.join("\r\n")
      end
    end
  end
end
