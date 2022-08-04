module Decisions
  class ContactDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :home_address
        edit('/steps/client/contact_details')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
