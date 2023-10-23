module Decisions
  class IncomeDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :x
        edit(:y)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
