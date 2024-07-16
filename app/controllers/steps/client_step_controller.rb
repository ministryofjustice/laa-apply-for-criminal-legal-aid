module Steps
  class ClientStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::ClientDecisionTree
    end

    def redirect_cifc
      return unless FeatureFlags.cifc_journey.enabled?

      redirect_to edit_crime_application_path(current_crime_application) if current_crime_application.cifc?
    end
  end
end
