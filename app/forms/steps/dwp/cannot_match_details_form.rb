module Steps
  module DWP
    class CannotMatchDetailsForm < Steps::BaseFormObject
      include Steps::SubjectIsBenefitCheckRecipient

      def persist!
        true
      end
    end
  end
end
