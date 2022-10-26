module Steps
  module Dwp
    class ConfirmDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :confirm_details, :value_object, source: YesNoAnswer

      validates_inclusion_of :confirm_details, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        true
      end
    end
  end
end
