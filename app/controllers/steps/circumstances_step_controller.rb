module Steps
  class CircumstancesStepController < BaseStepController
    before_action :redirect_non_cifc

    private

    def decision_tree_class
      Decisions::CircumstancesDecisionTree
    end

    def redirect_non_cifc

      redirect_to edit_crime_application_path(current_crime_application) unless current_crime_application.cifc?
    end
  end
end
