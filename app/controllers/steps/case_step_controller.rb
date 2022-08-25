# :nocov:
module Steps
  class CaseStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::CaseDecisionTree
    end
  end
end
# :nocov:
