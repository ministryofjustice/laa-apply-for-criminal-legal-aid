module Steps
  module DWP
    class CannotCheckDWPStatusForm < Steps::BaseFormObject
      include Steps::SubjectIsBenefitCheckRecipient

      def persist!
        true
      end
    end
  end
end
