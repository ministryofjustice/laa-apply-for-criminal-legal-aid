module Steps
  class ProviderStepController < BaseStepController
    skip_before_action :check_crime_application_presence,
                       :update_navigation_stack

    private

    def decision_tree_class
      Decisions::ProviderDecisionTree
    end
  end
end
