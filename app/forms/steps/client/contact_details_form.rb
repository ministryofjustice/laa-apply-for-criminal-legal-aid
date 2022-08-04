module Steps
  module Client
    class ContactDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant

      private

      def persist!
        applicant.update(
          attributes
        )
      end
    end
  end
end
