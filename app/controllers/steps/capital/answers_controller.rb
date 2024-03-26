module Steps
  module Capital
    class AnswersController < Steps::CapitalStepController
      before_action :set_presenter

      def edit
        @form_object = AnswersForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(AnswersForm, as: :answers)
      end

      private

      def set_presenter
        @presenter = Summary::HtmlPresenter.new(
          crime_application: current_crime_application
        )
      end
    end
  end
end
