module Steps
  module Capital
    class TrustFundController < Steps::CapitalStepController
      def edit
        @form_object = TrustFundForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(TrustFundForm, as: :trust_fund)
      end
    end
  end
end
