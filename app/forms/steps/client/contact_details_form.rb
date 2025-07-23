module Steps
  module Client
    class ContactDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      # Very basic validation to allow numeric and common telephone number symbols
      TEL_REGEXP = /\A[0-9#+()-.]{7,18}\z/

      attribute :telephone_number, :string
      attribute :correspondence_address_type, :value_object, source: CorrespondenceType
      attribute :welsh_correspondence

      validates :telephone_number,
                format: { with: TEL_REGEXP },
                allow_blank: true

      validates :correspondence_address_type,
                inclusion: { in: :choices }

      validates :welsh_correspondence,
                inclusion: { in: :choices },
                allow_blank: true

      def telephone_number=(str)
        super(str.delete(' ')) if str
      end

      def choices
        values = CorrespondenceType.values.dup
        values.delete(CorrespondenceType::HOME_ADDRESS) unless applicant.home_address?
        values.delete(CorrespondenceType::HOME_ADDRESS) if no_residence_type?

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

      def no_residence_type?
        applicant.residence_type.present? && applicant.residence_type == 'none'
      end
    end
  end
end
