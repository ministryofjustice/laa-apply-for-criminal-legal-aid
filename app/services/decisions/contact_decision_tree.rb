module Decisions
  class ContactDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :postcode_lookup
        edit(:home_address)
      when :home_address
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
