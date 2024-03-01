module Steps
  module Capital
    class PropertyAddressForm < Steps::BaseFormObject
      delegate :property_type, to: :record

      attribute :address
      attribute :address_line_one
      attribute :address_line_two
      attribute :city
      attribute :country
      attribute :postcode

      validates :address, presence: true

      validates_with AddressValidator

      private

      def persist!
        record.update(
          attributes
        )
      end
    end
  end
end
