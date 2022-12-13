module Steps
  module Submission
    class FailureController < Steps::SubmissionStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :submission_retry
      end
    end
  end
end
