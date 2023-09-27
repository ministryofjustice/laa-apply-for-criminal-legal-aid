module Steps
  class EvidenceStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::EvidenceDecisionTree
    end
  end
end
