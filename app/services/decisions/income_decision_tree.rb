module Decisions
  class IncomeDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :lost_job_in_custody
        # TODO: link to next step when we have it
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
