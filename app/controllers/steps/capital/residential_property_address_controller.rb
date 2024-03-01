module Steps
  module Capital
    class ResidentialPropertyAddressController < PropertyAddressController
      private

      def advance_as
        :residential_property_address
      end

      def form_name
        PropertyAddressForm
      end
    end
  end
end
