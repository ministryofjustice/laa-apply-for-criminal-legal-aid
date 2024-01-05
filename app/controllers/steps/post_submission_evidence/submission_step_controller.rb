module Steps
  module PostSubmissionEvidence
    class SubmissionStepController < BaseStepController
      private

      def decision_tree_class
        Decisions::PostSubmissionEvidence::SubmissionDecisionTree
      end
    end
  end
end
