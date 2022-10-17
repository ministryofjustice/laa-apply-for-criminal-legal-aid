module Steps
  module Submission
    class ReviewController < Steps::SubmissionStepController
      def edit
        @form_object = ReviewForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(ReviewForm, as: :review)
      end
    end
  end
end
