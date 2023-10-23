# :nocov:
module Steps
  class IncomeStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::IncomeDecisionTree
    end
  end
end
# :nocov:
