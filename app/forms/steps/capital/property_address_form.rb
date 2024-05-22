module Steps
  module Capital
    class PropertyAddressForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include ApplicantOrPartner

      delegate :property_type, :has_other_owners, to: :record

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
