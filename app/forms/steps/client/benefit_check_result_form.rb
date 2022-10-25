module Steps
  module Client
    class BenefitCheckResultForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant

      private

      def persist!
        true
      end
    end
  end
end
