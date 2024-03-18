module Steps
  class OutgoingsStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::OutgoingsDecisionTree
    end

    def current_housing_payment_type
      current_crime_application.outgoings&.housing_payment_type
    end
  end
end
