module Decisions
  class EvidenceDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :delete_document
        edit(:upload)
      when :upload_finished
        edit('/steps/submission/review')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
