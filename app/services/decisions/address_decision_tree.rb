module Decisions
  class AddressDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :lookup
        edit(:results)
      when :results
        edit(:details)
      when :details
        edit('/steps/client/contact_details')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
