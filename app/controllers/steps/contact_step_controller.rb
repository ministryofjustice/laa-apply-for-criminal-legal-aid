module Steps
  class ContactStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::ContactDecisionTree
    end
  end
end
