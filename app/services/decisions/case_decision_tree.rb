module Decisions
  class CaseDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :urn
        after_urn
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_urn; end
  end
end
end
