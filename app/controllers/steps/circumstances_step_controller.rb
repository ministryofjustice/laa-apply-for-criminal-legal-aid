module Steps
  class CircumstancesStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::CircumstancesDecisionTree
    end
  end
end
