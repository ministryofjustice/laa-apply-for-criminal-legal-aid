module Decisions
  class EvidenceDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :upload
        edit('/steps/submission/review')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
