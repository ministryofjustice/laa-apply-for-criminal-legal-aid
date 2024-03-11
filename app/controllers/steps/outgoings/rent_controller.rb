module Steps
  module Outgoings
    class RentController < Steps::OutgoingsStepController
      def edit
        @form_object = RentForm.build(current_crime_application)
      end

      def update
        update_and_advance(RentForm, as: :rent)
      end
    end
  end
end
