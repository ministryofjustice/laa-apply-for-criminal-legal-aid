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
    end
  end
end
