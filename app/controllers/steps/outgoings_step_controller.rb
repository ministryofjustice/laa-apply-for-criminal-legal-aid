module Steps
  class OutgoingsStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::OutgoingsDecisionTree
    end
  end
end
