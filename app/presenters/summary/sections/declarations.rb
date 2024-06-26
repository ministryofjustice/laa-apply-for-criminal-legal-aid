module Summary
  module Sections
    class Declarations < Sections::BaseSection
      def show?
        return false if crime_application.in_progress?

        true
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        answers =
          [
            Components::ValueAnswer.new(
              :legal_rep_has_client_declaration,
              'yes'
            )
          ]
        if provider_details.legal_rep_has_partner_declaration.present?
          answers.push(Components::ValueAnswer.new(
                         :legal_rep_has_partner_declaration,
                         provider_details.legal_rep_has_partner_declaration,
                       ))
        end

        if provider_details.legal_rep_has_partner_declaration == 'no' &&
           provider_details.legal_rep_no_partner_declaration_reason
          answers.push(Components::FreeTextAnswer.new(
                         :legal_rep_no_partner_declaration_reason,
                         provider_details.legal_rep_no_partner_declaration_reason,
                       ))
        end

        answers.flatten.select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def provider_details
        @provider_details ||= crime_application.provider_details
      end
    end
  end
end
