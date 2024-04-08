module Steps
  module Outgoings
    class AnswersController < Steps::OutgoingsStepController
      include Steps::NoOpAdvanceStep
      before_action :set_presenter

      private

      def advance_as
        :answers
      end

      def set_presenter
        @presenter = Summary::HtmlPresenter.new(
          crime_application: current_crime_application
        )
      end
    end
  end
end
