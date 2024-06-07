module Steps
  module DWP
    class BenefitCheckResultForm < Steps::BaseFormObject
      include Steps::SubjectIsBenefitCheckRecipient

      def persist!
        true
      end
    end
  end
end
