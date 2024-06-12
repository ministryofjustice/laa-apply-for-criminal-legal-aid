module Steps
  module Capital
    class PartnerPremiumBondsController < Steps::CapitalStepController
      def edit
        @form_object = PartnerPremiumBondsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PartnerPremiumBondsForm, as: :partner_premium_bonds)
      end
    end
  end
end
