module Steps
  module Client
    class RetryBenefitCheckForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      private

      def persist!
        true
      end
    end
  end
end
