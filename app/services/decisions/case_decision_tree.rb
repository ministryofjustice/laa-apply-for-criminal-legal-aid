module Decisions
  class CaseDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :has_urn
        after_has_urn
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_has_urn; end
  end
end
