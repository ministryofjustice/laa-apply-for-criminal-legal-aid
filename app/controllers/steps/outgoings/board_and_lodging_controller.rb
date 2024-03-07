module Steps
  module Outgoings
    class BoardAndLodgingController < Steps::OutgoingsStepController
      def edit
        @form_object = BoardAndLodgingForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(BoardAndLodgingForm, as: :board_and_lodging)
      end
    end
  end
end
