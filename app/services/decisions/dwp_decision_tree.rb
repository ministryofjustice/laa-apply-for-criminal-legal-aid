module Decisions
  class DWPDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :confirm_result
        after_confirm_result
      when :confirm_details
        after_confirm_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_confirm_result
      if form_object.confirm_result.yes? # Do we want to reset their ppt benefit to None if they select Yes here?
        if FeatureFlags.means_journey.enabled?
          edit('steps/client/benefit_type')
        else
          show(:benefit_check_result_exit)
        end
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
