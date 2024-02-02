module Steps
  class PartnerStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::PartnerDecisionTree
    end
  end
end
