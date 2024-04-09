module Decisions
  class DWPDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :confirm_result
        after_confirm_result
      when :confirm_details
        after_confirm_details
      when :cannot_check_dwp_status
        after_cannot_check_dwp_status
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_cannot_check_dwp_status
      edit('steps/client/has_benefit_evidence')
    end

    def after_confirm_result
      if form_object.confirm_result.yes?
        show(:benefit_check_result_exit)
      else
        edit(:confirm_details)
      end
    end

    def after_confirm_details
      if form_object.confirm_details.yes?
        edit('steps/client/has_benefit_evidence')
      else
        edit('steps/client/details')
      end
    end
  end
end
