module Steps
  module Client
    class ConfirmDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant

      attr_accessor :confirm_details

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
