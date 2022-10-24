module Decisions
  class SubmissionDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :review
        edit(:declaration)
      when :declaration
        show(:confirmation)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
