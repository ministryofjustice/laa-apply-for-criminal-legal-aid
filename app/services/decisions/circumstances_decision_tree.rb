module Decisions
  class CircumstancesDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :pre_cifc_reference_number
        edit('/steps/client/details')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
