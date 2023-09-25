module Steps
  module Client
    class HasBenefitEvidenceForm < Steps::BaseFormObject
      attribute :has_benefit_evidence, :value_object, source: YesNoAnswer

      validates_inclusion_of :has_benefit_evidence, in: :choices

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
