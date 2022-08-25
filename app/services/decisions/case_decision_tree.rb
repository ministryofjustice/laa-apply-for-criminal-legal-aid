module Decisions
  class CaseDecisionTree < BaseDecisionTree
    # :nocov:
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
    # :nocov:
  end
end
