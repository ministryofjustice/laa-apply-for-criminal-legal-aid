module Steps
  module DWP
    class HasBenefitEvidencePartnerForm < Steps::DWP::HasBenefitEvidenceForm
      include Steps::HasOneAssociation

      has_one_association :partner

      private

      def persist!
        partner.update(
          attributes
        )
      end
    end
  end
end
