module SubmissionSerializer
  module Sections
    class ProviderDetails < Sections::BaseSection
      def to_builder # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        Jbuilder.new do |json|
          json.provider_details do
            json.office_code crime_application.office_code
            json.provider_email crime_application.provider_email
            json.legal_rep_has_partner_declaration rep_has_partner_declaration
            json.legal_rep_no_partner_declaration_reason(
              crime_application.legal_rep_no_partner_declaration_reason
            )
            json.legal_rep_first_name crime_application.legal_rep_first_name
            json.legal_rep_last_name crime_application.legal_rep_last_name
            json.legal_rep_telephone crime_application.legal_rep_telephone
          end
        end
      end

      private

      def rep_has_partner_declaration
        return unless crime_application.legal_rep_has_partner_declaration

        crime_application.legal_rep_has_partner_declaration['value']
      end
    end
  end
end
