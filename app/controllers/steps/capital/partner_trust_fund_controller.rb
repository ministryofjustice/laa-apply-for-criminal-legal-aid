module Steps
  module Capital
    class PartnerTrustFundController < Steps::CapitalStepController
      def edit
        @form_object = PartnerTrustFundForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PartnerTrustFundForm, as: :partner_trust_fund)
      end
    end
  end
end
