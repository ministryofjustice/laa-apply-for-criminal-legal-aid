module Steps
  module DWP
    class HasBenefitEvidenceForm < Steps::DWP::DWPBaseForm
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :has_benefit_evidence, :value_object, source: YesNoAnswer
      validate :has_benefit_evidence_selected

      def choices
        YesNoAnswer.values
      end

      def benefit_type
        return partner.benefit_type if partner_has_benefit?

        applicant.benefit_type
      end

      private

      def persist!
        applicant.update(
          attributes
        )
      end

      def has_benefit_evidence_selected
        return if YesNoAnswer.values.include?(has_benefit_evidence) # rubocop:disable Performance/InefficientHashSearch

        errors.add(:has_benefit_evidence, :blank, subject:)
      end
    end
  end
end
