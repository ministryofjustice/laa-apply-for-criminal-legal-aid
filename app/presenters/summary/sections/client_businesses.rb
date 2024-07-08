module Summary
  module Sections
    class ClientBusinesses < Businesses
      private

      def businesses
        return if income.blank?

        income.client_businesses
      end
    end
  end
end
