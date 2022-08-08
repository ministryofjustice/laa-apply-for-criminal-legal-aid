module Steps
  module Client
    class ContactDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      # Very basic validation to prevent alphabetic input
      TEL_REGEXP = /\A([^A-Za-z]*)\Z/

      attribute :telephone_number, :string

      has_one_association :applicant

      validates :telephone_number, format: { with: TEL_REGEXP }, presence: true

      def telephone_number=(str)
        super(str.delete(' ')) if str
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
