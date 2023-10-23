module Decisions
  class IncomeDecisionTree < BaseDecisionTree
    def destination
      case step_name
      # :nocov:
      when :x
        edit(:y)
      # :nocov:
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
