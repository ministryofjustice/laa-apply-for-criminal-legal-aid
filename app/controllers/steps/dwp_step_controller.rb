module Steps
  class DWPStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::DWPDecisionTree
    end
  end
end
