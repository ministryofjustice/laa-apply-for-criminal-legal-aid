module Steps
  module DWP
    class CannotCheckBenefitStatusPartnerForm < Steps::DWP::CannotCheckBenefitStatusForm
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
