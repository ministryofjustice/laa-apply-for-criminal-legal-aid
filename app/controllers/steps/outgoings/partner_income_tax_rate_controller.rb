module Steps
  module Outgoings
    class PartnerIncomeTaxRateController < Steps::OutgoingsStepController
      def edit
        @form_object = PartnerIncomeTaxRateForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PartnerIncomeTaxRateForm, as: :partner_income_tax_rate)
      end
    end
  end
end
