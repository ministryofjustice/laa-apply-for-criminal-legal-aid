module Steps
  module Dwp
    class ConfirmDetailsForm < Steps::BaseFormObject
      attribute :confirm_details, :value_object, source: YesNoAnswer
      validates :confirm_details, inclusion: { in: :choices }

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
