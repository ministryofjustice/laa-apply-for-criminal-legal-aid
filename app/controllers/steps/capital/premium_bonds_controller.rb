module Steps
  module Capital
    class PremiumBondsController < Steps::CapitalStepController
      def edit
        @form_object = PremiumBondsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PremiumBondsForm, as: :premium_bonds)
      end
    end
  end
end
