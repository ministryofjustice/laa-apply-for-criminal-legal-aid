module Steps
  module Client
    class ContactDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      # Very basic validation to prevent alphabetic input
      TEL_REGEXP = /\A([^A-Za-z]*)\Z/

      attribute :telephone_number, :string

      attribute :correspondence_address_type, :string

      has_one_association :applicant

      validates :telephone_number,
                format: { with: TEL_REGEXP },
                presence: true

      validates :correspondence_address_type,
                inclusion: { in: :string_choices },
                presence: true

      def telephone_number=(str)
        super(str.delete(' ')) if str
      end

      def choices
        CorrespondenceTypeAnswer.values
      end

      private

      def string_choices
        choices.map { |choice| choice.value.to_s }
      end

      def persist!
        applicant.update(
          attributes
        )
      end
    end
  end
end
