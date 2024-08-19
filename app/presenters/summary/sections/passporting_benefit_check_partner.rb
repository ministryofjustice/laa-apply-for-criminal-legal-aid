module Summary
  module Sections
    class PassportingBenefitCheckPartner < Sections::PassportingBenefitCheck
      def show?
        super && include_partner_in_means_assessment?
      end

      def change_path
        nil
      end

      private

      def person
        @person ||= crime_application.partner
      end
    end
  end
end
