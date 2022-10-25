module Steps
  module Dwp
    class ConfirmResultForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      attribute :confirm_result, :value_object, source: YesNoAnswer

      has_one_association :applicant

      validates_inclusion_of :confirm_result, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        return true unless confirm_result.no?

        applicant.update(passporting_benefit: nil)
      end
    end
  end
end
