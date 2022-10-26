module Steps
  class DwpStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::DwpDecisionTree
    end
  end
end
