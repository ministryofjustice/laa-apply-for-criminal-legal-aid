module Steps
  module DWP
    class ConfirmResultForm < Steps::BaseFormObject
      attribute :confirm_result, :value_object, source: YesNoAnswer

      validates_inclusion_of :confirm_result, in: :choices

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
