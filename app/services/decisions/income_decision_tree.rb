module Decisions
  class IncomeDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :lost_job_in_custody
        # TODO: link to next step when we have it
        edit(:manage_without_income)
      when :manage_without_income
        # TODO: link to next step when we have it
        show('/home', action: :index)
      when :income_before_tax
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
