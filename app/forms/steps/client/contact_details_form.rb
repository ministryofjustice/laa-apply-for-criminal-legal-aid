module Steps
  module Client
    class ContactDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      # Very basic validation to allow numeric and common telephone number symbols
      TEL_REGEXP = /\A[0-9#+()-.]{7,18}\Z/

      attribute :telephone_number, :string
      attribute :correspondence_address_type, :value_object, source: CorrespondenceType

      validates :telephone_number,
                format: { with: TEL_REGEXP },
                presence: true

      validates :correspondence_address_type,
                inclusion: { in: :choices }

      def telephone_number=(str)
        super(str.delete(' ')) if str
      end

      def choices
        values = CorrespondenceType.values.dup
        values.delete(CorrespondenceType::HOME_ADDRESS) unless applicant.home_address?

        values
      end

      private

      def persist!
        applicant.update(
          attributes
        )
      end
    end
  end
end
