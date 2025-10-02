module Steps
  class ProviderStepController < BaseStepController
    skip_before_action :check_crime_application_presence,
                       :update_navigation_stack,
                       :block_contingent_liability!,
                       :require_current_office!

    private

    def decision_tree_class
      Decisions::ProviderDecisionTree
    end
  end
end
