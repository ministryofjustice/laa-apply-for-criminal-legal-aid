module Steps
  module Contact
    class DetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant_contact_details

      private

      def persist!
        applicant_contact_details.update(
          attributes
        )
      end
    end
  end
end
