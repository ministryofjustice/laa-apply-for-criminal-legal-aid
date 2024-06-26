module Steps
  module DWP
    class ConfirmResultForm < Steps::BaseFormObject
      include Steps::SubjectIsBenefitCheckRecipient

      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :confirm_dwp_result, :value_object, source: YesNoAnswer
      validates :confirm_dwp_result, inclusion: { in: :choices }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        applicant.update(attributes)

        return true if confirm_dwp_result.no?

        update_person_attributes if confirm_dwp_result.yes?
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
