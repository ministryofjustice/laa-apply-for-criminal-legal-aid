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

      def additional_permitted_params
        [address: [:address_line_one, :address_line_two, :city, :country, :postcode]]
      end
    end
  end
end
