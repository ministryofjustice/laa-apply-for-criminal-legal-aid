module Decisions
  class OutgoingsDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :outgoings_more_than_income
        # TODO: link to next step when we have it
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
