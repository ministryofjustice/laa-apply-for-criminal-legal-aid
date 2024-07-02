module Summary
  module Sections
    class ClientBusinesses < Businesses
      private

      def businesses
        crime_application.businesses
      end
    end
  end
end
