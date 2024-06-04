module Steps
  module DWP
    class HasBenefitEvidencePartnerForm < Steps::DWP::HasBenefitEvidenceForm
      include Steps::HasOneAssociation
      has_one_association :partner

      attribute :has_benefit_evidence, :value_object, source: YesNoAnswer
      validates :has_benefit_evidence, inclusion: { in: :choices }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        partner.update(
          attributes
        )
      end
    end
  end
end
