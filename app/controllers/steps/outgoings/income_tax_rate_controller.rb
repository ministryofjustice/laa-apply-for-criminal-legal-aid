module Steps
  module Outgoings
    class IncomeTaxRateController < Steps::OutgoingsStepController
      def edit
        @form_object = IncomeTaxRateForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(IncomeTaxRateForm, as: :income_tax_rate)
      end
    end
  end
end
