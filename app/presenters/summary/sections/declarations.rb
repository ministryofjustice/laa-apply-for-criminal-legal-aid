module Summary
  module Sections
    class Declarations < Sections::BaseSection
      def show?
        return false if crime_application.in_progress?

        true
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::ValueAnswer.new(
            :legal_rep_has_client_declaration,
            'yes'
          ),
          Components::ValueAnswer.new(
            :legal_rep_has_partner_declaration,
            provider_details.legal_rep_has_partner_declaration,
          ),
          Components::FreeTextAnswer.new(
            :legal_rep_no_partner_declaration_reason,
            provider_details.legal_rep_no_partner_declaration_reason,
          ),
        ]
      end
      # rubocop:enable Metrics/MethodLength

      private

      def provider_details
        @provider_details ||= crime_application.provider_details
      end
    end
  end
end
