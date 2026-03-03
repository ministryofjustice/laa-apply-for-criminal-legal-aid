module Steps
  module DWP
    class CannotCheckBenefitStatusForm < Steps::BaseFormObject
      include Steps::SubjectIsBenefitCheckRecipient

      include Steps::HasOneAssociation

      has_one_association :applicant

      attribute :will_enter_nino, :value_object, source: YesNoAnswer
      validates :will_enter_nino, inclusion: { in: :choices }

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
