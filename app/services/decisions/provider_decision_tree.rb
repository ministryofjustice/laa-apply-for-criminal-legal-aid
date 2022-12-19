module Decisions
  class ProviderDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :confirm_office
        # TODO: update when we have next step
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
