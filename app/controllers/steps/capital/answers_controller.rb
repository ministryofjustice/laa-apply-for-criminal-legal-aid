module Steps
  module Capital
    class AnswersController < Steps::CapitalStepController
      before_action :set_presenter

      def edit
        @form_object = AnswersForm.build(
          capital_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(AnswersForm, record: capital_record, as: :answers)
      end

      private

      def capital_record
        current_crime_application.capital
      end

      def set_presenter
        @presenter = Summary::HtmlPresenter.new(
          crime_application: current_crime_application
        )
      end
    end
  end
end
