module Steps
  module Contact
    class PostcodeLookupForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant_contact_details

      attribute :home_postcode, :string
      validates :home_postcode, presence: true

      private

      def persist!
        applicant_contact_details.update(
          attributes
        )
      end
    end
  end
end
