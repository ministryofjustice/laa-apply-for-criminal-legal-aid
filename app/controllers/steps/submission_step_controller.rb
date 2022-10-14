module Steps
  class SubmissionStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::SubmissionDecisionTree
    end
  end
end
