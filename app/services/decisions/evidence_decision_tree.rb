module Decisions
  class EvidenceDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :delete_document
        edit(:upload)
      when :upload_finished
        after_upload_finished
      when :additional_information
        edit('/steps/submission/review')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_upload_finished
      if FeatureFlags.additional_information.enabled?
        edit(:additional_information)
      else
        edit('/steps/submission/review')
      end
    end
  end
end
