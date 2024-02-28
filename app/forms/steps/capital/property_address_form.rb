module Steps
  module Capital
    class PropertyAddressForm < Steps::BaseFormObject
      delegate :property_type, to: :record

      attribute :address

      validates_with AddressValidator

      def address_line_one
        address[:address_line_one]
      end

      def address_line_two
        address[:address_line_two]
      end

      def city
        address[:city]
      end

      def country
        address[:country]
      end

      def postcode
        address[:postcode]
      end

      private

      def persist!
        record.update(
          attributes
        )
      end
    end
  end
end
