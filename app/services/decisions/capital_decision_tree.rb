module Decisions
  class CapitalDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :savings
        # TODO: Add next step
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
