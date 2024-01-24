module Steps
  module Outgoings
    class CouncilTaxController < Steps::OutgoingsStepController
      def edit
        @form_object = CouncilTaxForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(CouncilTaxForm, as: :council_tax)
      end

      private

      def additional_permitted_params
        [:council_tax_amount_in_pounds]
      end
    end
  end
end
