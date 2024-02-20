module Steps
  class CapitalStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::CapitalDecisionTree
    end
  end
end
