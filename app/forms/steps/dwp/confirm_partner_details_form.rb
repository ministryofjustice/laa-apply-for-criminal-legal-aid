module Steps
  module DWP
    class ConfirmPartnerDetailsForm < Steps::DWP::ConfirmDetailsForm
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
