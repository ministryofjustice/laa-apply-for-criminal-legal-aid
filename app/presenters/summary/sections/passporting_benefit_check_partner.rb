module Summary
  module Sections
    class PassportingBenefitCheckPartner < Sections::PassportingBenefitCheck
      def show?
        client_has_partner?
      end

      def change_path
        nil
      end

      private

      def person
        @person ||= crime_application.partner
      end

      def client_has_partner?
        crime_application.applicant.has_partner == 'yes'
      end
    end
  end
end
