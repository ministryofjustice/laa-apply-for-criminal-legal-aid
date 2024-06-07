module Steps
  class DWPStepController < BaseStepController
    include TypeOfMeansAssessment

    private

    def decision_tree_class
      Decisions::DWPDecisionTree
    end

    def benefit_check_on_partner?
      return false unless include_partner_in_means_assessment?
      return true if current_crime_application.partner&.has_passporting_benefit?

      false
    end

    def crime_application
      current_crime_application
    end
  end
end
