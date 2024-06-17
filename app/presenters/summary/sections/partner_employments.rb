module Summary
  module Sections
    class PartnerEmployments < Summary::Sections::Employments
      private

      def employments
        @employments ||= crime_application.partner_employments
      end
    end
  end
end
