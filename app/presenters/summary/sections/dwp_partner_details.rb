module Summary
  module Sections
    class DWPPartnerDetails < Sections::BaseSection
      def show?
        partner.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
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
            change_path: edit_steps_partner_details_path, show: true
          ),

          Components::DateAnswer.new(
            :date_of_birth, partner.date_of_birth,
            change_path: edit_steps_partner_details_path
          ),

          Components::FreeTextAnswer.new(
            :nino, partner.nino,
            change_path: edit_steps_partner_nino_path
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def name
        :details
      end

      private

      def partner
        @partner ||= crime_application.partner
      end
    end
  end
end
