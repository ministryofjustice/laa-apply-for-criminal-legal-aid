module Decisions
  class IncomeDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :employment_status
        after_employment_status
      when :lost_job_in_custody
        # TODO: link to next step when we have it
        edit(:manage_without_income)
      when :manage_without_income
        # TODO: link to next step when we have it
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_employment_status
      if not_working
        if ended_employment_within_three_months
          edit(:lost_job_in_custody)
        else
          show('/home', action: :index)
        end
      else
        show(:employed_exit)
      end
    end

    def not_working
      form_object.employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
    end

    def ended_employment_within_three_months
      form_object.ended_employment_within_three_months&.yes?
    end
  end
end
