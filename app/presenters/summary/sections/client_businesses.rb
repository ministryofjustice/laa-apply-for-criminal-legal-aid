module Summary
  module Sections
    class ClientBusinesses < Businesses
      private

      def businesses
        income.client_businesses
      end
    end
  end
end
