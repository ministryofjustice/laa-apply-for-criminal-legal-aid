module Steps
  class ClientStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::ClientDecisionTree
    end
  end
end
