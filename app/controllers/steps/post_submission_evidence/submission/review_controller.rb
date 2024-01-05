module Steps
  module PostSubmissionEvidence
    module Submission
      class ReviewController < Steps::PostSubmissionEvidence::SubmissionStepController
        include Steps::NoOpAdvanceStep

        before_action :set_presenter

        private

        def advance_as
          :review
        end

        def set_presenter
          @presenter = Summary::HtmlPresenter.new(
            crime_application: current_crime_application
          )
        end
      end
    end
  end
end
