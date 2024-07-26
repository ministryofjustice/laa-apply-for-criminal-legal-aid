module Steps
  module Submission
    class ReviewController < Steps::SubmissionStepController
      before_action :set_presenter

      def edit
        @form_object = ReviewForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ReviewForm, as: :review)
      end

      private

      def set_presenter
        @presenter = Summary::HtmlPresenter.new(
          crime_application: current_crime_application.draft_submission
        )
      rescue Dry::Struct::Error => e
        Rails.error.report(e, handled: true)

        redirect_to edit_crime_application_path(current_crime_application)
      end
    end
  end
end
