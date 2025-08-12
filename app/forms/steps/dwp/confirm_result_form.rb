module Steps
  module DWP
    class ConfirmResultForm < Steps::BaseFormObject
      include Steps::SubjectIsBenefitCheckRecipient

      include Steps::HasOneAssociation
      has_one_association :applicant

      private

      def persist!
        update_person_attributes
      end

      def update_person_attributes
        applicant.update(attributes_to_update)
      end

      def attributes_to_update
        {
          'benefit_type' => BenefitType::NONE,
          'has_benefit_evidence' => nil,
          'confirm_details' => nil
        }
      end
    end
  end
end
