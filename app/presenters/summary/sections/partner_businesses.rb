module Summary
  module Sections
    class PartnerBusinesses < Businesses
      private

      def businesses
        income.partner_businesses
      end
    end
  end
end
