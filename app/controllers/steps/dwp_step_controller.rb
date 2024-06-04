module Steps
  class DWPStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::DWPDecisionTree
    end

    def benefit_check_on_partner?
      return true if current_crime_application.partner&.has_passporting_benefit?

      false
    end
  end
end
