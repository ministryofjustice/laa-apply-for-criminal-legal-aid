module Steps
  module Contact
    class HomeAddressForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant_contact_details

      attribute :home_address_line_one, :string
      attribute :home_address_line_two, :string
      attribute :home_city, :string
      attribute :home_county, :string
      attribute :home_postcode, :string

      validates_presence_of :home_address_line_one,
                            :home_city,
                            :home_postcode

      private

      def persist!
        applicant_contact_details.update(
          attributes
        )
      end
    end
  end
end
