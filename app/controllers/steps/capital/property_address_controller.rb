module Steps
  module Capital
    class PropertyAddressController < Steps::CapitalStepController
      include Steps::Capital::PropertyUpdateStep

      private

      def advance_as
        :property_address
      end

      def form_name
        PropertyAddressForm
      end

      def additional_permitted_params
        [{ address: [:address_line_one, :address_line_two, :city, :country, :postcode] }]
      end
    end
  end
end
