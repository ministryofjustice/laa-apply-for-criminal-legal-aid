module Steps
  module Capital
    class PropertyAddressForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include ApplicantOrPartner

      delegate :property_type, :has_other_owners, to: :record

      attribute :address_line_one
      attribute :address_line_two
      attribute :city
      attribute :country
      attribute :postcode

      validates_presence_of :address_line_one,
                            :city,
                            :country,
                            :postcode

      private

      def persist!
        return true unless changed?

        record.update(attributes)
      end
    end
  end
end
