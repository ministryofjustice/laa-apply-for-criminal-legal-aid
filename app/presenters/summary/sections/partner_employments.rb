module Summary
  module Sections
    class PartnerEmployments < Summary::Sections::ClientEmployments
      private

      def employments
        @employments ||= income.partner_employments
      end
    end
  end
end
