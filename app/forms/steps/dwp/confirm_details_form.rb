module Steps
  module DWP
    class ConfirmDetailsForm < Steps::BaseFormObject
      include Steps::SubjectIsBenefitCheckRecipient

      include Steps::HasOneAssociation

      has_one_association :applicant

      attribute :confirm_details, :value_object, source: YesNoAnswer
      validates :confirm_details, inclusion: { in: :choices }

      def choices
        YesNoAnswer.values
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
