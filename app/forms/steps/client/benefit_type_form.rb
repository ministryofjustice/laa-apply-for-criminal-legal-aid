module Steps
  module Client
    class BenefitTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :benefit_type, :value_object, source: BenefitType

      validates_inclusion_of :benefit_type, in: :choices

      def choices
        BenefitType.values
      end

      private

      def changed?
        # The attribute is a `value_object`, overriding generic `#changed?`
        !applicant.benefit_type.eql?(benefit_type.to_s)
      end

      def persist!
        return true unless changed?

        applicant.update(
          attributes
        )
      end
    end
  end
end
