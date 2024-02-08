module Decisions
  class EvidenceDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :delete_document
        edit(:upload)
      when :upload_finished
        submission_root_step
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def submission_root_step
      if FeatureFlags.more_information.enabled?
        edit('/steps/submission/more_information')
      else
        edit('/steps/submission/review')
      end
    end
  end
end
