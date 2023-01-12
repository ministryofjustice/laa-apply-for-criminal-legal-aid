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
                allow_blank: true

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
          attributes.merge(
            reset_address_if_needed
          )
        )
      end

      def reset_address_if_needed
        {}.tap do |attrs|
          attrs.merge!(correspondence_address: nil) unless correspondence_address_type.other_address?
        end
      end
    end
  end
end
