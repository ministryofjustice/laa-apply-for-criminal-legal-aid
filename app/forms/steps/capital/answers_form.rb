module Steps
  module Capital
    class AnswersForm < Steps::BaseFormObject
      # include OwnershipConfirmation

      def persist!
        true
      end
    end
  end
end
