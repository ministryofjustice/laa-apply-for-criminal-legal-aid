module Decisions
  class ContactDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :home_address
        edit(:details)
      when :details
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
