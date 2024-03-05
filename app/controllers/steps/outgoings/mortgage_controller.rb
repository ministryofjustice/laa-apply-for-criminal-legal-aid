module Steps
  module Outgoings
    class MortgageController < Steps::OutgoingsStepController
      def edit
        @form_object = MortgageForm.build(current_crime_application)
      end

      def update
        update_and_advance(MortgageForm, as: :mortgage)
      end
    end
  end
end
