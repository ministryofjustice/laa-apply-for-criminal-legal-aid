module Steps
  module DWP
    class HasBenefitEvidenceForm < Steps::BaseFormObject
      include Steps::ApplicantOrPartnerExclusive

      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :has_benefit_evidence, :value_object, source: YesNoAnswer
      validates :has_benefit_evidence, inclusion: { in: :choices }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        applicant.update(
          attributes
        )
      end

      def has_benefit_evidence_selected
        errors.add(:has_benefit_evidence, :inclusion, subject:)
      end
    end
  end
end
